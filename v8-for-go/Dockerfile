# build this and tag it 'v8-for-go'
#    from the above directory:
#       docker build -t v8-for-go v8-for-go

FROM donovan/golang:1.3
RUN apt-get install -y pkg-config
ADD . /build/src/github.com/idada/v8.go
RUN cd /build/src/github.com/idada/v8.go ; MAKE_OPTIONS=-j4 ./install.sh
