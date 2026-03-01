import os
import cv2
import numpy as np

from blueprint.blueprint_model import BlueprintModel
from mesh_builder import MeshBuilder
from geometry.region_splitter import split_front_regions, region_bbox
from geometry.leg_splitter import split_legs_by_x


def main():
    # -------------------------------------------------
    # PATH SETUP
    # -------------------------------------------------
    base_dir = os.path.dirname(os.path.dirname(__file__))
    image_path = os.path.join(
        base_dir,
        "assets",
        "blueprints",
        "chairblueprint1.jpg"
    )

    if not os.path.exists(image_path):
        raise FileNotFoundError(f"Blueprint not found: {image_path}")

    # -------------------------------------------------
    # STAGE 1 – BLUEPRINT → POINT CLOUD
    # -------------------------------------------------
    model = BlueprintModel(image_path)

    model.load_image()
    model.preprocess()
    model.split_views()

    # Dimensions
    front_w, front_h = model.extract_dimensions("front")
    model.extract_dimensions("side")

    # SCALE MUST COME HERE
    model.compute_scale(front_h, real_height_cm=90.0)

    # THEN contours
    front_contour = model.extract_contour("front")
    side_contour = model.extract_contour("side")

    # THEN point cloud
    point_cloud = model.generate_2_5d_point_cloud()

    model.save_point_cloud("stage1_chair_pointcloud.txt")

    print("\nSTAGE-1 COMPLETE")

    # -------------------------------------------------
    # STAGE 2 – POINT CLOUD → DEBUG MESH
    # -------------------------------------------------
    points = np.loadtxt("stage1_chair_pointcloud.txt")

    mesh = MeshBuilder(points)
    mesh.build_front_surface()
    mesh.add_thickness(thickness_cm=2.5)
    mesh.export_obj("chair_stage2_debug.obj")

    print("STAGE-2 COMPLETE (debug mesh)")

    # -------------------------------------------------
    # STAGE 3 – FRONT VIEW REGION SPLIT
    # -------------------------------------------------
    front_pts = front_contour.reshape(-1, 2)
    regions = split_front_regions(front_pts)

    print("\n=== REGION SPLIT (FRONT VIEW) ===")
    for name, pts in regions.items():
        bbox = region_bbox(pts)
        print(f"{name.upper()} bbox (px): {bbox}")

    # -------------------------------------------------
    # STAGE 3B – LEG CLUSTERING
    # -------------------------------------------------
    leg_pts = regions["legs"]
    leg_clusters = split_legs_by_x(leg_pts)

    print("\n=== LEG CLUSTERS ===")
    for name, pts in leg_clusters.items():
        xs, ys = pts[:, 0], pts[:, 1]
        print(
            f"{name.upper():<12} "
            f"x:[{xs.min():.0f}-{xs.max():.0f}] "
            f"y:[{ys.min():.0f}-{ys.max():.0f}] "
            f"pts={len(pts)}"
        )

    print("\nPIPELINE OK — READY FOR STAGE 4 (LEG GEOMETRY)")


if __name__ == "__main__":
    main()