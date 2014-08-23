FROM v8-for-go
ADD . /build/src/github.com/idada/v8.go
RUN cd /build/src/github.com/idada/v8.go ; PATH=/usr/local/go/bin:$PATH MAKE_OPTIONS=-j4 ./install.sh
