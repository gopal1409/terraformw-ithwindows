resource "aws_key_pair" "mykey" { #this resource will attach and existing key pair to your instance
    key_name = "mykey" #this is the name of the key
    public_key = file(var.PATH_TO_PUBLIC_KEY) #it will look for the key in your current directory
}
resource "aws_instance" "win-example" { #will launch an instance
    ami = data.aws_ami.windows-ami.image_id #this ami field will come from var file
    instance_type = "t2.micro"
    key_name = aws_key_pair.mykey.key_name #once the instance it has launch it will attach the key pair
    user_data     = <<EOF
<powershell>
net user ${var.INSTANCE_USERNAME} '${var.INSTANCE_PASSWORD}' /add /y
net localgroup administrators ${var.INSTANCE_USERNAME} /add
winrm quickconfig -q
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="300"}'
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
netsh advfirewall firewall add rule name="WinRM 5985" protocol=TCP dir=in localport=5985 action=allow
netsh advfirewall firewall add rule name="WinRM 5986" protocol=TCP dir=in localport=5986 action=allow
net stop winrm
sc.exe config winrm start=auto
net start winrm
</powershell>
EOF


  provisioner "file" {
    source = "test.txt"
    destination = "C:/test.txt"
  }
  connection {
    host = coalesce(self.public_ip, self.private_ip)
    type = "winrm"
    timeout = "10m"
    user = var.INSTANCE_USERNAME
    password = var.INSTANCE_PASSWORD
  }
}
