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

    # Show original
    cv2.imshow("1. ORIGINAL BLUEPRINT", cv2.resize(model.image, (800, 800)))
    cv2.waitKey(0)
    cv2.destroyAllWindows()

    # Show front & side
    front = cv2.resize(model.views["front"], (350, 350))
    side = cv2.resize(model.views["side"], (350, 350))
    cv2.imshow("2. FRONT | SIDE", np.hstack([front, side]))
    cv2.waitKey(0)
    cv2.destroyAllWindows()

    # Dimensions
    front_w, front_h = model.extract_dimensions("front")
    model.extract_dimensions("side")

    # Scale (known real height)
    model.compute_scale(front_h, real_height_cm=90.0)

    # Contours
    front_contour = model.extract_contour("front")
    side_contour = model.extract_contour("side")

    # Generate point cloud
    point_cloud = model.generate_2_5d_point_cloud()

    if point_cloud is None or len(point_cloud) < 50:
        raise ValueError("Point cloud generation failed")

    print("\nSample 3D points (cm):")
    print(point_cloud[:10])

    model.save_point_cloud("stage1_chair_pointcloud.txt")

    print("\nSTAGE-1 COMPLETE")
    print("Clean 2.5D point cloud generated")

    # -------------------------------------------------
    # STAGE 2 – POINT CLOUD → MESH
    # -------------------------------------------------
    points = np.loadtxt("stage1_chair_pointcloud.txt")

    mesh = MeshBuilder(points)
    mesh.build_front_surface()
    mesh.add_thickness(thickness_cm=2.5)
    mesh.export_obj("chair_stage2.obj")

    print("\nSTAGE-2 COMPLETE")
    print("Solid 3D chair mesh exported")

    # -------------------------------------------------
    # STAGE 3 – FRONT VIEW REGION SPLIT (SEMANTIC STEP)
    # -------------------------------------------------

    front_pts = front_contour.reshape(-1, 2)

    regions = split_front_regions(front_pts)

    print("\n=== REGION SPLIT (FRONT VIEW) ===")

    for name, pts in regions.items():
        bbox = region_bbox(pts)
        if bbox:
            print(f"{name.upper()} bbox (px): {bbox}")
        else:
            print(f"{name.upper()} region empty")

    # -------------------------------
    # STAGE 3B – LEG CLUSTERING
    # -------------------------------
    leg_pts = regions["legs"]

    leg_clusters = split_legs_by_x(leg_pts)

    print("\n=== LEG CLUSTERS ===")
    for name, pts in leg_clusters.items():
        xs = pts[:,0]
        ys = pts[:,1]
        print(
            f"{name.upper():<12} "
            f"x:[{xs.min():.0f}-{xs.max():.0f}] "
            f"y:[{ys.min():.0f}-{ys.max():.0f}] "
            f"pts={len(pts)}"
        )


if __name__ == "__main__":
    main()