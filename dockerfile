FROM klakegg/hugo
WORKDIR /src
ADD . /src
EXPOSE 1313
CMD ["server"]