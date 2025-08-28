# ---- Stage: test (build & run unit tests) ----
FROM python:3.11-slim AS test
WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
COPY app/requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt pytest
COPY app/ .
# Run unit tests
RUN pytest -q

# ---- Stage: runtime (production image) ----
FROM python:3.11-slim
WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
COPY app/requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt gunicorn
COPY app/ .
EXPOSE 5000
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]
