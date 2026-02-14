import cv2


class BlueprintModel:
    def __init__(self, image_path):
        self.image_path = image_path
        self.image = None
        self.gray = None
        self.edges = None
        self.views = {}
        self.dimensions = {}

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

    def split_views(self):
        h, w = self.edges.shape

        front = self.edges[0:h//2, 0:w//2]
        side = self.edges[0:h//2, w//2:w]
        top = self.edges[h//2:h, 0:w//2]

        self.views = {
            "front": front,
            "side": side,
            "top": top
        }

        print("Blueprint views separated")
        return self.views

    def extract_dimensions(self, view_name):
        view = self.views[view_name]

        contours, _ = cv2.findContours(
            view, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE
        )

        valid_contours = [
            c for c in contours if cv2.contourArea(c) > 500
        ]

        if not valid_contours:
            raise ValueError(f"No valid contours in {view_name}")

        largest = max(valid_contours, key=cv2.contourArea)
        x, y, w, h = cv2.boundingRect(largest)

        self.dimensions[view_name] = {"width": w, "height": h}

        print(f"{view_name.upper()} dimensions (pixels): width={w}, height={h}")
        return w, h

    def extract_contour(self, view_name):
        view = self.views[view_name]

        contours, _ = cv2.findContours(
            view, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE
        )

        valid_contours = [
            c for c in contours if cv2.contourArea(c) > 500
        ]

        main_contour = max(valid_contours, key=cv2.contourArea)
        print(f"{view_name.upper()} contour points:", len(main_contour))
        return main_contour

    def get_main_bbox(self, contours):
        all_x, all_y, all_w, all_h = [], [], [], []

        for cnt in contours:
            x, y, w, h = cv2.boundingRect(cnt)
            all_x.append(x)
            all_y.append(y)
            all_w.append(w)
            all_h.append(h)

        x_min = min(all_x)
        y_min = min(all_y)
        x_max = max([x + w for x, w in zip(all_x, all_w)])
        y_max = max([y + h for y, h in zip(all_y, all_h)])

        return x_min, y_min, x_max, y_max
    
    def get_all_contours(self, view_name):
        view = self.views[view_name]

        contours, _ = cv2.findContours(
            view, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE
        )

        if not contours:
            raise ValueError(f"No contours found in {view_name}")

        return contours
    
    def segment_front_parts(self):
        contours = self.get_all_contours("front")
        h, _ = self.views["front"].shape
        seat_top, seat_bottom = self.detect_seat_band()

        # clamp thickness
        if seat_bottom - seat_top > 50:
            seat_bottom = seat_top + 50


        seat_top, seat_bottom = self.detect_seat_band()

        parts = {
            "backrest": [],
            "seat": [],
            "legs": []
        }

        for cnt in contours:
            x, y, w, h_cnt = cv2.boundingRect(cnt)
            cy = y + h_cnt // 2

            if cy < seat_top:
                parts["backrest"].append(cnt)
            elif cy <= seat_bottom:
                parts["seat"].append(cnt)
            else:
                parts["legs"].append(cnt)

        return parts

    
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
                "width": x2 - x1,
                "height": y2 - y1,
                "bbox": (x1, y1, x2, y2)
            }

        return dims
    
    def detect_seat_band(self):
        front = self.views["front"]
        h, w = front.shape

        row_density = front.sum(axis=1)
        row_density = row_density / row_density.max()

        # seat = densest horizontal band
        seat_rows = [i for i, v in enumerate(row_density) if v > 0.6]

        if not seat_rows:
            raise ValueError("Seat band not detected")

        seat_top = min(seat_rows)
        seat_bottom = max(seat_rows)

        return seat_top, seat_bottom
    
    def detect_seat_band(self):
        front = self.views["front"]
        h, w = front.shape

        row_edges = (front > 0).sum(axis=1)

        # Normalize
        row_edges = row_edges / row_edges.max()

        # Candidate rows (moderate density, not extreme)
        candidates = [i for i, v in enumerate(row_edges) if 0.15 < v < 0.45]

        if not candidates:
            raise ValueError("Seat candidates not found")

        # Group continuous rows
        bands = []
        band = [candidates[0]]

        for r in candidates[1:]:
            if r == band[-1] + 1:
                band.append(r)
            else:
                bands.append(band)
                band = [r]
        bands.append(band)

        # Seat = widest thin band
        seat_band = min(bands, key=lambda b: abs(len(b) - 15))

        return min(seat_band), max(seat_band)




