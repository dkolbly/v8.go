FROM donovan/golang:1.2.2
RUN apt-get install -y pkg-config
ADD . /build/src/github.com/idada/v8.go
RUN cd /build/src/github.com/idada/v8.go ; PATH=/usr/local/go/bin:$PATH MAKE_OPTIONS=-j4 ./install.sh
