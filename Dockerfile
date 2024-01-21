FROM scratch
COPY simple-app /simple-app

USER 10000
 
ENTRYPOINT ["/simple-app"]
