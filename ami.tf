#data source to retrive windows ami
data "aws_ami" "windows_ami"{
    most_recent = true
    owner = ["amazon"]

    filter {
        name = "name"
        values = ["Windows_Server-2019-English-Full-Base-2020.*"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
    filter {
        name = "architecture"
        values = ["x86_64"]
    }
}