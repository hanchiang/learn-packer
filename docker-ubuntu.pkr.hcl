packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source  = "github.com/hashicorp/docker"
    }
  }
}

variable "docker_image" {
  type    = string
  default = "ubuntu:xenial"
}

# The source block configures a specific builder plugin, which is then invoked by a build block
# A source can be reused across multiple builds, and you can use multiple sources in a single build.
# source <build type> <name>
source "docker" "ubuntu" {
  image  = var.docker_image
  commit = true
}

source "docker" "ubuntu-bionic" {
  image  = "ubuntu:bionic"
  commit = true
}

# The build block defines what Packer should do with the Docker container after it launches.
build {
  name = "learn-packer"
  # references the Docker image defined by the source block above
  sources = [
    "source.docker.ubuntu",
    "sources.docker.ubuntu-bionic"
  ]
  provisioner "shell" {
    environment_vars = [
      "FOO=hello world"
    ]
    inline = [
      "echo Running ${var.docker_image} docker image.",
      "echo Adding file to docker container.",
      "echo \"FOO is $FOO\" > example.txt"
    ]
  }
  post-processor "docker-tag" {
    repository = "learn-packer"
    tags       = ["ubuntu-xenial", "packer-rocks"]
    only       = ["docker.ubuntu"]
  }
  post-processor "docker-tag" {
    repository = "learn-packer"
    tags       = ["ubuntu-bionic", "packer-rocks"]
    only       = ["docker.ubuntu-bionic"]
  }

  # Sequential post processing steps.
  # The output of one post-processor becomes the input to another post-processor.
  # post-processors {
  #   post-processor "docker-import" {
  #     repository = "swampdragons/testpush"
  #     tag        = "0.7"
  #   }
  #   post-processor "docker-push" {}
  # }
}

