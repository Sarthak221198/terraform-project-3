# Define an AWS Key Pair resource
# - `key_name`: Sets the name of the key pair to "client_key".
# - `public_key`: Specifies the path to the public key file that will be used to create the key pair.
#   The `file` function reads the contents of the public key file (`client_key.pub`) located in the specified path.
#   This public key will be used to allow SSH access to EC2 instances that use this key pair.
# Key Generation:
# - The key pair was generated using a tool like `ssh-keygen`.
# - Example command: `ssh-keygen -t rsa -b 4096 -f ./modules/key/client_key
resource "aws_key_pair" "client_key" {
    key_name = "client_key"
    public_key = file("./modules/key/client_key.pub")
}