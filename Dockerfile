FROM phusion/baseimage:0.11 as builder

ARG PROFILE=release
WORKDIR /kulupu

COPY . /kulupu

RUN git submodule update --init --recursive

RUN apt-get update && \
	apt-get dist-upgrade -y && \
	apt-get install -y cmake pkg-config libssl-dev git clang
  
RUN /kulupu/scripts/init.sh

# ===== SECOND STAGE ======

FROM phusion/baseimage:0.11
ARG PROFILE=release

RUN mkdir -p /root/.local/share && \
	ln -s /root/.local/share /data

COPY --from=builder /kulupu/target/$PROFILE/kulupu /usr/local/bin

# checks
RUN ldd /usr/local/bin/kulupu && \
	/usr/local/bin/kulupu --version

# Shrinking
RUN rm -rf /usr/lib/python* && \
	rm -rf /usr/bin /usr/sbin /usr/share/man

USER kulupu
EXPOSE 30333 9933 9944
VOLUME ["/data"]

CMD ["/usr/local/bin/kulupu"]
