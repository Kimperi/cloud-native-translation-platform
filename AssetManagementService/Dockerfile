FROM python:3.13-slim

WORKDIR /app

RUN groupadd --system app \
    && useradd --system --gid app --no-create-home app

COPY requirements.txt .

RUN python -m pip install --no-cache-dir -r requirements.txt

COPY --chown=app:app . .

RUN mkdir -p /app/data /app/generated-reports \
    && chown -R app:app /app/data /app/generated-reports

USER app

EXPOSE 8000

CMD ["python", "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
