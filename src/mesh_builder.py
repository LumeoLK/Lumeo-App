import numpy as np
from scipy.spatial import Delaunay


class MeshBuilder:
    def __init__(self, points_3d):
        """
        points_3d: (N, 3) numpy array in cm
        """
        if points_3d.shape[1] != 3:
            raise ValueError("Points must be (N,3)")

        self.points = points_3d
        self.vertices = []
        self.faces = []

    # -------------------------------------------------
    # 1. FRONT SURFACE (DELAUNAY)
    # -------------------------------------------------
    def build_front_surface(self):
        xy = self.points[:, :2]

        if len(xy) < 3:
            raise ValueError("Not enough points for triangulation")

        tri = Delaunay(xy)

        self.vertices = self.points.tolist()
        self.faces = tri.simplices.tolist()

        print(f"Front surface triangulated ({len(self.faces)} faces)")
        return self.vertices, self.faces

    # -------------------------------------------------
    # 2. ADD THICKNESS (FRONT → BACK)
    # -------------------------------------------------
    def add_thickness(self, thickness_cm=2.5):
        base_count = len(self.vertices)

        # Back vertices
        back_vertices = [
            [x, y, z - thickness_cm] for x, y, z in self.vertices
        ]

        self.vertices.extend(back_vertices)

        # Back faces (reverse winding)
        back_faces = []
        for f in self.faces:
            back_faces.append([
                f[0] + base_count,
                f[2] + base_count,
                f[1] + base_count
            ])

        self.faces.extend(back_faces)

        print("Thickness added (front + back surfaces)")
        return self.vertices, self.faces

    # -------------------------------------------------
    # 3. EXPORT OBJ
    # -------------------------------------------------
    def export_obj(self, filename):
        with open(filename, "w") as f:
            for v in self.vertices:
                f.write(f"v {v[0]:.4f} {v[1]:.4f} {v[2]:.4f}\n")

            for face in self.faces:
                f.write(
                    f"f {face[0]+1} {face[1]+1} {face[2]+1}\n"
                )

        print(f"Mesh exported → {filename}")