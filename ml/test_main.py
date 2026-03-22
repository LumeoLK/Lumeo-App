from fastapi.testclient import TestClient
from PIL import Image
import io
import ml_service

client = TestClient(ml_service.app)


def create_test_image(color=(255, 255, 255), size=(100, 100)):
    img = Image.new("RGB", size, color)
    buf = io.BytesIO()
    img.save(buf, format="PNG")
    buf.seek(0)
    return buf


def test_greet():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Lumeo ML Service is Online"}


def test_compute_color_score_same_color():
    score = ml_service.compute_color_score([255, 255, 255], [255, 255, 255])
    assert score == 1.0


def test_compute_color_score_missing_values():
    score = ml_service.compute_color_score(None, [255, 255, 255])
    assert score == 0.0


def test_is_room_image_plain_image():
    img = Image.new("RGB", (100, 100), (255, 255, 255))
    assert not ml_service.is_room_image(img)


def test_product_metadata_success(monkeypatch):
    def mock_analyze_image_features(image, remove_bg=False):
        return [0.1, 0.2, 0.3], [120, 130, 140]

    monkeypatch.setattr(ml_service, "analyze_image_features", mock_analyze_image_features)

    img_file = create_test_image()

    response = client.post(
        "/api/v1/product-metadata",
        files={"file": ("test.png", img_file, "image/png")}
    )

    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert data["data"]["rgb"] == [120, 130, 140]
    assert data["data"]["vector"] == [0.1, 0.2, 0.3]


def test_search_invalid_file_type():
    fake_file = io.BytesIO(b"not an image")

    response = client.post(
        "/api/v1/search",
        files={"file": ("test.txt", fake_file, "text/plain")}
    )

    assert response.status_code == 400
    assert response.json()["detail"] == "Invalid image type"