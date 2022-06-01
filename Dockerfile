# convert poetry's pyproject.toml into a requirements.txt file
FROM python:3.10 as requirements-stage
WORKDIR /tmp
RUN pip install poetry
COPY ./pyproject.toml ./poetry.lock* /tmp/
RUN poetry export -f requirements.txt --output requirements.txt --without-hashes

# actual app deployment
FROM python:3.10
RUN apt update && apt install -y usbutils zlib1g libjpeg-dev
COPY --from=requirements-stage /tmp/requirements.txt /requirements.txt
RUN pip install --no-cache-dir --upgrade -r /requirements.txt
COPY ./src /src
WORKDIR /src
HEALTHCHECK --interval=5s --timeout=3s --start-period=5s --retries=12 \
    CMD curl --fail http://localhost:8083/docs || exit 1
ENTRYPOINT ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8083"]
