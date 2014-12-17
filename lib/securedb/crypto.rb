require 'openssl'

module SecureDB
  Crypto = Class.new

  def Crypto::init
    @@engine = OpenSSL::Cipher::AES.new 128, :CBC
    if File.exist? '/etc/SecureDB/kpri.pem'
      @@signer = OpenSSL::PKey::DSA.new(File.read '/etc/SecureDB/kpri.pem')
      @@verifyer = OpenSSL::PKey::DSA.new(File.read '/etc/SecureDB/kpub.cer')
    else
      @@signer = OpenSSL::PKey::DSA.new 1024
      File.write '/etc/SecureDB/kpri.pem', @@signer.export
      File.write '/etc/SecureDB/kpub.cer', @@signer.public_key.export
    end
  end

  def Crypto::encrypt plain, key
    @@engine.encrypt
    @@engine.key = key
    @@engine.update(plain) + @@engine.final
  end

  def Crypto::decrypt cipher, key
    @@engine.decrypt
    @@engine.key = key
    @@engine.update(cipher) + @@engine.final
  end

  def Crypto::sign digest
    @@signer.syssign digest
  end

  def Crypto::verify digest, sig
    @@signer.sysverify digest, sig
  end
end
