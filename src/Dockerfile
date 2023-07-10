FROM nginx

COPY nginx.conf /etc/nginx/nginx.conf
COPY conf.d /etc/nginx/conf.d

COPY nimTermbin /opt/ 
COPY nimTermbin.conf /opt/ 

EXPOSE 9999 9999
COPY entrypoint.sh /opt/entrypoint.sh
CMD ["bash", "/opt/entrypoint.sh"]

