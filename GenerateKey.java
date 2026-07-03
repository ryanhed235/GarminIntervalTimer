import java.io.FileOutputStream;
import java.security.KeyPair;
import java.security.KeyPairGenerator;

public class GenerateKey {
    public static void main(String[] args) throws Exception {
        KeyPairGenerator kpg = KeyPairGenerator.getInstance("RSA");
        kpg.initialize(4096);
        KeyPair kp = kpg.generateKeyPair();
        
        // In Java, getEncoded() on a PrivateKey returns the key in PKCS#8 DER format!
        byte[] privateKey = kp.getPrivate().getEncoded(); 
        
        try (FileOutputStream fos = new FileOutputStream("developer_key.der")) {
            fos.write(privateKey);
        }
        System.out.println("developer_key.der generated successfully!");
    }
}
