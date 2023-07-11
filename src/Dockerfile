FROM nginx

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/conf.d /etc/nginx/conf.d
COPY index.html /var/www/default/

COPY nimTermbin /opt/ 
COPY nimTermbin.conf /opt/ 

RUN apt update && apt install libmagic-dev -y

EXPOSE 9999 9999
EXPOSE 8000 80

COPY entrypoint.sh /opt/entrypoint.sh
CMD ["bash", "/opt/entrypoint.sh"]

