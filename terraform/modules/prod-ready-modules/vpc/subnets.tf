resource "aws_subnet" "public" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.cidr_block, 8, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name                                        = format("%s-%s-public-subnet-${count.index + 1}-${element(var.availability_zones, count.index)}", var.tags["environment"], var.tags["project"])
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.control_plane_name}" = "shared"
    },
  )
}

resource "aws_subnet" "private" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, count.index + length(var.availability_zones))
  availability_zone = element(var.availability_zones, count.index)

  tags = merge(var.tags, {
    Name                                        = format("%s-%s-private-subnet-${count.index + 1}-${element(var.availability_zones, count.index)}", var.tags["environment"], var.tags["project"])
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.control_plane_name}" = "shared"
    },
  )
}