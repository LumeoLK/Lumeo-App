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
