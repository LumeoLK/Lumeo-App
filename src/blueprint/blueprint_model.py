import cv2


class BlueprintModel:
    def __init__(self, image_path):
        self.image_path = image_path
        self.image = None
        self.gray = None
        self.edges = None
        self.views = {}

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

        # Simple grid-based split (assumption-based)
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

        # Find contours
        contours, _ = cv2.findContours(
            view, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE
        )

        if not contours:
            raise ValueError(f"No contours found in {view_name} view")

        # Get largest contour (main shape)
        largest = max(contours, key=cv2.contourArea)

        x, y, w, h = cv2.boundingRect(largest)

        print(f"{view_name.upper()} dimensions (pixels): width={w}, height={h}")

        return w, h
