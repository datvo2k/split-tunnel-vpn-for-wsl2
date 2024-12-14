FROM gcc AS buildenv

RUN git clone https://github.com/3proxy/3proxy.git

RUN cd 3proxy &&\
    echo "">> Makefile.Linux && \
    echo PLUGINS = StringsPlugin TrafficPlugin PCREPlugin TransparentPlugin SSLPlugin>>Makefile.Linux && \
    echo LIBS = -l:libcrypto.a -l:libssl.a -ldl >>Makefile.Linux && \
    make -f Makefile.Linux && \
    strip bin/3proxy && \
    strip bin/StringsPlugin.ld.so && \
    strip bin/TrafficPlugin.ld.so && \
    strip bin/PCREPlugin.ld.so && \
    strip bin/TransparentPlugin.ld.so && \
    strip bin/SSLPlugin.ld.so && \
    mkdir /usr/local/lib/3proxy && \
    cp "/lib/`gcc -dumpmachine`"/libdl.so.* /usr/local/lib/3proxy/


FROM linuxserver/wireguard:latest

COPY --from=buildenv /usr/local/lib/3proxy/libdl.so.* /lib/
COPY --from=buildenv 3proxy/bin/3proxy /bin/
COPY --from=buildenv 3proxy/bin/*.ld.so /usr/local/3proxy/libexec/
RUN mkdir /usr/local/3proxy/logs && \
    mkdir /usr/local/3proxy/conf && \
    chown -R 65535:65535 /usr/local/3proxy && \
    chmod -R 550  /usr/local/3proxy && \
    chmod 750  /usr/local/3proxy/logs && \
    chmod -R 555 /usr/local/3proxy/libexec && \
    chown -R root /usr/local/3proxy/libexec && \
    mkdir /etc/3proxy/

COPY ./config/3proxy.cfg /etc/3proxy/3proxy.cfg
RUN chown 65535:65535 /etc/3proxy/3proxy.cfg
EXPOSE 6667
CMD ["/bin/3proxy", "/etc/3proxy/3proxy.cfg"]