import numpy as np

def split_front_regions(front_contour_pts):
    """
    front_contour_pts: numpy array of shape (N, 2) -> (x, y) in px

    Returns dict with leg / seat / back regions
    """

    # Separate X and Y
    x = front_contour_pts[:, 0]
    y = front_contour_pts[:, 1]

    y_min, y_max = y.min(), y.max()
    height = y_max - y_min

    # Define vertical zones (percent-based)
    leg_limit = y_min + 0.30 * height
    seat_limit = y_min + 0.60 * height

    legs = front_contour_pts[y <= leg_limit]
    seat = front_contour_pts[(y > leg_limit) & (y <= seat_limit)]
    back = front_contour_pts[y > seat_limit]

    regions = {
        "legs": legs,
        "seat": seat,
        "back": back
    }

    return regions


def region_bbox(points):
    """
    Compute bounding box of a region
    """
    if len(points) == 0:
        return None

    x_min, y_min = points.min(axis=0)
    x_max, y_max = points.max(axis=0)

    return (x_min, y_min, x_max, y_max)