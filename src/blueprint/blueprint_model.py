import cv2
import numpy as np

class BlueprintModel:
    def __init__(self, image_path):
        self.image_path = image_path
        self.image = None
        self.gray = None
        self.edges = None
        self.views = {}
        self.dimensions = {}

    # -------------------------------------------------
    # LOAD & PREPROCESS
    # -------------------------------------------------
    def load_image(self):
        self.image = cv2.imread(self.image_path)
        if self.image is None:
            raise ValueError("Blueprint image could not be loaded")

        print("Blueprint image loaded successfully")
        return self.image

    def preprocess(self):
        self.gray = cv2.cvtColor(self.image, cv2.COLOR_BGR2GRAY)
        self.edges = cv2.Canny(self.gray, 50, 150)
        print("Blueprint preprocessing completed")
        return self.edges

    # -------------------------------------------------
    # VIEW SPLITTING
    # -------------------------------------------------
    def split_views(self):
        h, w = self.edges.shape

        front = self.edges[0:h // 2, 0:w // 2]
        side = self.edges[0:h // 2, w // 2:w]
        top = self.edges[h // 2:h, 0:w // 2]

        self.views = {
            "front": front,
            "side": side,
            "top": top
        }

        print("Blueprint views separated")
        return self.views

    # -------------------------------------------------
    # BASIC DIMENSIONS
    # -------------------------------------------------
    def extract_dimensions(self, view_name):
        view = self.views[view_name]

        contours, _ = cv2.findContours(
            view, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE
        )

        valid = [c for c in contours if cv2.contourArea(c) > 500]
        if not valid:
            raise ValueError(f"No valid contours in {view_name}")

        largest = max(valid, key=cv2.contourArea)
        x, y, w, h = cv2.boundingRect(largest)

        self.dimensions[view_name] = {"width": w, "height": h}
        print(f"{view_name.upper()} dimensions (pixels): width={w}, height={h}")
        return w, h

    # -------------------------------------------------
    # CONTOURS
    # -------------------------------------------------
    def extract_contour(self, view_name):
        view = self.views[view_name]

        contours, _ = cv2.findContours(
            view, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE
        )

        valid = [c for c in contours if cv2.contourArea(c) > 500]
        if not valid:
            raise ValueError(f"No contours in {view_name}")

        main = max(valid, key=cv2.contourArea)
        print(f"{view_name.upper()} contour points:", len(main))
        return main

    def get_all_contours(self, view_name):
        view = self.views[view_name]

        contours, _ = cv2.findContours(
            view, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE
        )

        return [c for c in contours if cv2.contourArea(c) > 300]

    # -------------------------------------------------
    # SEAT DETECTION (STABLE)
    # -------------------------------------------------
    def detect_seat_band(self):
        front = self.views["front"]

        row_edges = (front > 0).sum(axis=1)
        row_edges = row_edges / row_edges.max()

        candidates = [i for i, v in enumerate(row_edges) if 0.15 < v < 0.45]
        if not candidates:
            raise ValueError("Seat candidates not found")

        bands = []
        band = [candidates[0]]

        for r in candidates[1:]:
            if r == band[-1] + 1:
                band.append(r)
            else:
                bands.append(band)
                band = [r]
        bands.append(band)

        # seat = thin horizontal band (~15px)
        seat_band = min(bands, key=lambda b: abs(len(b) - 15))
        return min(seat_band), max(seat_band)

    # -------------------------------------------------
    # FRONT PART SEGMENTATION
    # -------------------------------------------------
    def segment_front_parts(self):
        front = self.views["front"]
        H, W = front.shape

        # get ONLY main contour
        contours = self.get_all_contours("front")
        main = max(contours, key=cv2.contourArea)

        seat_top = int(H * 0.40)
        seat_bottom = int(H * 0.55)

        parts = {
            "backrest": [],
            "seat": [],
            "legs": []
        }

        for p in main:
            x, y = p[0]

            if y < seat_top:
                parts["backrest"].append([[x, y]])
            elif y <= seat_bottom:
                parts["seat"].append([[x, y]])
            else:
                parts["legs"].append([[x, y]])

        # convert point lists to contours
        for k in parts:
            if parts[k]:
                parts[k] = [np.array(parts[k], dtype=np.int32)]
            else:
                parts[k] = []

        return parts

    # -------------------------------------------------
    # DIMENSIONS PER PART
    # -------------------------------------------------
    def bounding_box_from_contours(self, contours):
        xs, ys, xe, ye = [], [], [], []

        for cnt in contours:
            x, y, w, h = cv2.boundingRect(cnt)
            xs.append(x)
            ys.append(y)
            xe.append(x + w)
            ye.append(y + h)

        return min(xs), min(ys), max(xe), max(ye)

    def extract_front_part_dimensions(self):
        parts = self.segment_front_parts()
        dims = {}

        for part, contours in parts.items():
            if not contours:
                continue

            x1, y1, x2, y2 = self.bounding_box_from_contours(contours)

            dims[part] = {
                "width": int(x2 - x1),
                "height": int(y2 - y1),
                "bbox": (x1, y1, x2, y2)
            }

        return dims

