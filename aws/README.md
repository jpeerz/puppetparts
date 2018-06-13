# Creating AWS Cloud Machine

    virtualenv pylibs
    source pylibs/bin/activate
    pip install awscli --upgrade

## ready to create stack

    git clone https://github.com/jpeerz/puppetparts.git
    cd puppetparts/aws/
    aws cloudformation validate-template --template-body file://`pwd`/ubuntu_xenial_with_puppet.cf.json

    aws cloudformation create-stack  --stack-name xenialpuppet \
    --template-body file://`pwd`/ubuntu_xenial_with_puppet.cf.json \
    --parameters ParameterKey=KeyName,ParameterValue=webadmin ParameterKey=Vpc,ParameterValue=vpc-5b3d0b3d  ParameterKey=SubnetId,ParameterValue=subnet-5e1c6438

## base ubuntu xenial

    aws cloudformation create-stack  --stack-name xenialpuppet \
    --template-body file://`pwd`/ubuntu_xenial.cf.json \
    --parameters 

## review and connect to new machine

    ssh -i ~/.ssh/webadmin.pem ubuntu@ec2-54-245-203-83.us-west-2.compute.amazonaws.com
