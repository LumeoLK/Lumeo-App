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

        self.scale_factor = None
        self.front_contour = None
        self.side_contour = None

        self.point_cloud = None

    # -------------------------------------------------
    # LOAD & PREPROCESS
    # -------------------------------------------------
    def load_image(self):
        self.image = cv2.imread(self.image_path)
        if self.image is None:
            raise ValueError("Blueprint image could not be loaded")
        print("Blueprint image loaded successfully")

    def preprocess(self):
        self.gray = cv2.cvtColor(self.image, cv2.COLOR_BGR2GRAY)
        blurred = cv2.GaussianBlur(self.gray, (5, 5), 0)
        self.edges = cv2.Canny(blurred, 50, 150)
        print("Blueprint preprocessing completed")

    # -------------------------------------------------
    # VIEW SPLITTING
    # -------------------------------------------------
    def split_views(self):
        h, w = self.edges.shape
        self.views["front"] = self.edges[0:h // 2, 0:w // 2]
        self.views["side"]  = self.edges[0:h // 2, w // 2:w]
        print("Blueprint views separated")

    # -------------------------------------------------
    # DIMENSIONS
    # -------------------------------------------------
    def extract_dimensions(self, view_name):
        view = self.views[view_name]
        contours, _ = cv2.findContours(view, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        valid = [c for c in contours if cv2.contourArea(c) > 500]
        largest = max(valid, key=cv2.contourArea)
        _, _, w, h = cv2.boundingRect(largest)
        self.dimensions[view_name] = {"width": w, "height": h}
        print(f"{view_name.upper()} dimensions (px): {w} x {h}")
        return w, h

    # -------------------------------------------------
    # CONTOURS
    # -------------------------------------------------
    def extract_contour(self, view_name):
        view = self.views[view_name]
        contours, _ = cv2.findContours(view, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)
        valid = [c for c in contours if cv2.contourArea(c) > 500]
        main = max(valid, key=cv2.contourArea)
        print(f"{view_name.upper()} contour points: {len(main)}")
        return main

    # -------------------------------------------------
    # SCALE
    # -------------------------------------------------
    def compute_scale(self, pixel_height, real_height_cm):
        self.scale_factor = real_height_cm / pixel_height
        print(f"Scale factor: 1 px = {self.scale_factor:.4f} cm")

    # -------------------------------------------------
    # REAL DIMENSIONS
    # -------------------------------------------------
    def get_real_dimensions_cm(self):
        return {
            "width":  self.dimensions["front"]["width"] * self.scale_factor,
            "height": self.dimensions["front"]["height"] * self.scale_factor,
            "depth":  self.dimensions["side"]["width"] * self.scale_factor
        }

    # -------------------------------------------------
    # POINT CLOUD
    # -------------------------------------------------
    def generate_2_5d_point_cloud(self):
        self.front_contour = self.extract_contour("front")
        self.side_contour  = self.extract_contour("side")

        front_pts = self.front_contour.reshape(-1, 2) * self.scale_factor
        side_pts  = self.side_contour.reshape(-1, 2) * self.scale_factor

        depth_map = {}
        for x, y in side_pts:
            depth_map.setdefault(round(y, 2), []).append(x)

        cloud = []
        for x, y in front_pts:
            z = np.mean(depth_map.get(round(y, 2), [0]))
            cloud.append([x, y, z])

        self.point_cloud = np.array(cloud, dtype=np.float32)
        print("2.5D point cloud generated:", self.point_cloud.shape)
        return self.point_cloud

    def save_point_cloud(self, filename):
        np.savetxt(filename, self.point_cloud, fmt="%.3f")
        print(f"Saved point cloud → {filename}")