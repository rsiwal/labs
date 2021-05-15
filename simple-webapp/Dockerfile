FROM python:slim
RUN useradd -d /app app -m
USER app
WORKDIR /app
ADD . /app
RUN pip install --no-warn-script-location --trusted-host pypi.python.org Flask
RUN pip install --no-warn-script-location  --trusted-host pypi.python.org python-dotenv
ENV COLOR red
EXPOSE $APP_PORT
ENV PATH ${PATH}:/app/.local/bin/
CMD ["python", "app.py"]
