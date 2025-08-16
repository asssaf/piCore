: ${IMAGE:=asssaf/service-serial}
: ${TCZ:=service-serial.tcz}

docker build --build-arg TCZ=${TCZ} -t ${IMAGE} -f docker/Dockerfile --output build .
