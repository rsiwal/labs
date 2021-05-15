FROM python:slim
WORKDIR /app
ADD . /app
RUN pip install --trusted-host pypi.python.org Flask
ENV COLOR red
EXPOSE 8080/tcp
CMD ["python", "app.py"]
