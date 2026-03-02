import numpy as np

class PartMeshBuilder:
    def __init__(self):
        self.vertices = []
        self.faces = []
        self.v_offset = 0

    def add_cuboid(self, x, y, z, w, d, h):
        """
        Add a cuboid defined by:
        (x, y, z) = bottom-front-left corner
        w = width (x)
        d = depth (z)
        h = height (y)
        """

        v = np.array([
            [x,     y,     z],
            [x+w,   y,     z],
            [x+w,   y+h,   z],
            [x,     y+h,   z],
            [x,     y,     z+d],
            [x+w,   y,     z+d],
            [x+w,   y+h,   z+d],
            [x,     y+h,   z+d],
        ])

        f = np.array([
            [0,1,2],[0,2,3],     # front
            [4,5,6],[4,6,7],     # back
            [0,1,5],[0,5,4],     # bottom
            [2,3,7],[2,7,6],     # top
            [1,2,6],[1,6,5],     # right
            [0,3,7],[0,7,4],     # left
        ]) + self.v_offset

        self.vertices.extend(v)
        self.faces.extend(f)
        self.v_offset += 8

    def export_obj(self, path):
        with open(path, "w") as f:
            for v in self.vertices:
                f.write(f"v {v[0]:.4f} {v[1]:.4f} {v[2]:.4f}\n")
            for face in self.faces:
                f.write(
                    f"f {face[0]+1} {face[1]+1} {face[2]+1}\n"
                )