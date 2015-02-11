## Macintosh Terminal App File Encryptor/Decryptor using openssl

## Usage

- Encyption example:
openssl des3 -salt -in 1.png -out 2.txt -k pass1

- Decryption example:
openssl des3 -d -salt -in 2.txt -out 3.png -k pass1