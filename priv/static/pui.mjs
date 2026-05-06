// js/popover.js
import { ViewHook } from "phoenix_live_view";

// node_modules/@floating-ui/utils/dist/floating-ui.utils.mjs
var sides = ["top", "right", "bottom", "left"];
var min = Math.min;
var max = Math.max;
var round = Math.round;
var floor = Math.floor;
var createCoords = (v) => ({
  x: v,
  y: v
});
var oppositeSideMap = {
  left: "right",
  right: "left",
  bottom: "top",
  top: "bottom"
};
var oppositeAlignmentMap = {
  start: "end",
  end: "start"
};
function clamp(start, value, end) {
  return max(start, min(value, end));
}
function evaluate(value, param) {
  return typeof value === "function" ? value(param) : value;
}
function getSide(placement) {
  return placement.split("-")[0];
}
function getAlignment(placement) {
  return placement.split("-")[1];
}
function getOppositeAxis(axis) {
  return axis === "x" ? "y" : "x";
}
function getAxisLength(axis) {
  return axis === "y" ? "height" : "width";
}
var yAxisSides = /* @__PURE__ */ new Set(["top", "bottom"]);
function getSideAxis(placement) {
  return yAxisSides.has(getSide(placement)) ? "y" : "x";
}
function getAlignmentAxis(placement) {
  return getOppositeAxis(getSideAxis(placement));
}
function getAlignmentSides(placement, rects, rtl) {
  if (rtl === void 0) {
    rtl = false;
  }
  const alignment = getAlignment(placement);
  const alignmentAxis = getAlignmentAxis(placement);
  const length = getAxisLength(alignmentAxis);
  let mainAlignmentSide = alignmentAxis === "x" ? alignment === (rtl ? "end" : "start") ? "right" : "left" : alignment === "start" ? "bottom" : "top";
  if (rects.reference[length] > rects.floating[length]) {
    mainAlignmentSide = getOppositePlacement(mainAlignmentSide);
  }
  return [mainAlignmentSide, getOppositePlacement(mainAlignmentSide)];
}
function getExpandedPlacements(placement) {
  const oppositePlacement = getOppositePlacement(placement);
  return [getOppositeAlignmentPlacement(placement), oppositePlacement, getOppositeAlignmentPlacement(oppositePlacement)];
}
function getOppositeAlignmentPlacement(placement) {
  return placement.replace(/start|end/g, (alignment) => oppositeAlignmentMap[alignment]);
}
var lrPlacement = ["left", "right"];
var rlPlacement = ["right", "left"];
var tbPlacement = ["top", "bottom"];
var btPlacement = ["bottom", "top"];
function getSideList(side, isStart, rtl) {
  switch (side) {
    case "top":
    case "bottom":
      if (rtl) return isStart ? rlPlacement : lrPlacement;
      return isStart ? lrPlacement : rlPlacement;
    case "left":
    case "right":
      return isStart ? tbPlacement : btPlacement;
    default:
      return [];
  }
}
function getOppositeAxisPlacements(placement, flipAlignment, direction, rtl) {
  const alignment = getAlignment(placement);
  let list = getSideList(getSide(placement), direction === "start", rtl);
  if (alignment) {
    list = list.map((side) => side + "-" + alignment);
    if (flipAlignment) {
      list = list.concat(list.map(getOppositeAlignmentPlacement));
    }
  }
  return list;
}
function getOppositePlacement(placement) {
  return placement.replace(/left|right|bottom|top/g, (side) => oppositeSideMap[side]);
}
function expandPaddingObject(padding) {
  return {
    top: 0,
    right: 0,
    bottom: 0,
    left: 0,
    ...padding
  };
}
function getPaddingObject(padding) {
  return typeof padding !== "number" ? expandPaddingObject(padding) : {
    top: padding,
    right: padding,
    bottom: padding,
    left: padding
  };
}
function rectToClientRect(rect2) {
  const {
    x,
    y,
    width,
    height
  } = rect2;
  return {
    width,
    height,
    top: y,
    left: x,
    right: x + width,
    bottom: y + height,
    x,
    y
  };
}

// node_modules/@floating-ui/core/dist/floating-ui.core.mjs
function computeCoordsFromPlacement(_ref, placement, rtl) {
  let {
    reference,
    floating
  } = _ref;
  const sideAxis = getSideAxis(placement);
  const alignmentAxis = getAlignmentAxis(placement);
  const alignLength = getAxisLength(alignmentAxis);
  const side = getSide(placement);
  const isVertical = sideAxis === "y";
  const commonX = reference.x + reference.width / 2 - floating.width / 2;
  const commonY = reference.y + reference.height / 2 - floating.height / 2;
  const commonAlign = reference[alignLength] / 2 - floating[alignLength] / 2;
  let coords;
  switch (side) {
    case "top":
      coords = {
        x: commonX,
        y: reference.y - floating.height
      };
      break;
    case "bottom":
      coords = {
        x: commonX,
        y: reference.y + reference.height
      };
      break;
    case "right":
      coords = {
        x: reference.x + reference.width,
        y: commonY
      };
      break;
    case "left":
      coords = {
        x: reference.x - floating.width,
        y: commonY
      };
      break;
    default:
      coords = {
        x: reference.x,
        y: reference.y
      };
  }
  switch (getAlignment(placement)) {
    case "start":
      coords[alignmentAxis] -= commonAlign * (rtl && isVertical ? -1 : 1);
      break;
    case "end":
      coords[alignmentAxis] += commonAlign * (rtl && isVertical ? -1 : 1);
      break;
  }
  return coords;
}
var computePosition = async (reference, floating, config) => {
  const {
    placement = "bottom",
    strategy = "absolute",
    middleware = [],
    platform: platform2
  } = config;
  const validMiddleware = middleware.filter(Boolean);
  const rtl = await (platform2.isRTL == null ? void 0 : platform2.isRTL(floating));
  let rects = await platform2.getElementRects({
    reference,
    floating,
    strategy
  });
  let {
    x,
    y
  } = computeCoordsFromPlacement(rects, placement, rtl);
  let statefulPlacement = placement;
  let middlewareData = {};
  let resetCount = 0;
  for (let i = 0; i < validMiddleware.length; i++) {
    const {
      name,
      fn
    } = validMiddleware[i];
    const {
      x: nextX,
      y: nextY,
      data,
      reset
    } = await fn({
      x,
      y,
      initialPlacement: placement,
      placement: statefulPlacement,
      strategy,
      middlewareData,
      rects,
      platform: platform2,
      elements: {
        reference,
        floating
      }
    });
    x = nextX != null ? nextX : x;
    y = nextY != null ? nextY : y;
    middlewareData = {
      ...middlewareData,
      [name]: {
        ...middlewareData[name],
        ...data
      }
    };
    if (reset && resetCount <= 50) {
      resetCount++;
      if (typeof reset === "object") {
        if (reset.placement) {
          statefulPlacement = reset.placement;
        }
        if (reset.rects) {
          rects = reset.rects === true ? await platform2.getElementRects({
            reference,
            floating,
            strategy
          }) : reset.rects;
        }
        ({
          x,
          y
        } = computeCoordsFromPlacement(rects, statefulPlacement, rtl));
      }
      i = -1;
    }
  }
  return {
    x,
    y,
    placement: statefulPlacement,
    strategy,
    middlewareData
  };
};
async function detectOverflow(state, options) {
  var _await$platform$isEle;
  if (options === void 0) {
    options = {};
  }
  const {
    x,
    y,
    platform: platform2,
    rects,
    elements,
    strategy
  } = state;
  const {
    boundary = "clippingAncestors",
    rootBoundary = "viewport",
    elementContext = "floating",
    altBoundary = false,
    padding = 0
  } = evaluate(options, state);
  const paddingObject = getPaddingObject(padding);
  const altContext = elementContext === "floating" ? "reference" : "floating";
  const element = elements[altBoundary ? altContext : elementContext];
  const clippingClientRect = rectToClientRect(await platform2.getClippingRect({
    element: ((_await$platform$isEle = await (platform2.isElement == null ? void 0 : platform2.isElement(element))) != null ? _await$platform$isEle : true) ? element : element.contextElement || await (platform2.getDocumentElement == null ? void 0 : platform2.getDocumentElement(elements.floating)),
    boundary,
    rootBoundary,
    strategy
  }));
  const rect2 = elementContext === "floating" ? {
    x,
    y,
    width: rects.floating.width,
    height: rects.floating.height
  } : rects.reference;
  const offsetParent = await (platform2.getOffsetParent == null ? void 0 : platform2.getOffsetParent(elements.floating));
  const offsetScale = await (platform2.isElement == null ? void 0 : platform2.isElement(offsetParent)) ? await (platform2.getScale == null ? void 0 : platform2.getScale(offsetParent)) || {
    x: 1,
    y: 1
  } : {
    x: 1,
    y: 1
  };
  const elementClientRect = rectToClientRect(platform2.convertOffsetParentRelativeRectToViewportRelativeRect ? await platform2.convertOffsetParentRelativeRectToViewportRelativeRect({
    elements,
    rect: rect2,
    offsetParent,
    strategy
  }) : rect2);
  return {
    top: (clippingClientRect.top - elementClientRect.top + paddingObject.top) / offsetScale.y,
    bottom: (elementClientRect.bottom - clippingClientRect.bottom + paddingObject.bottom) / offsetScale.y,
    left: (clippingClientRect.left - elementClientRect.left + paddingObject.left) / offsetScale.x,
    right: (elementClientRect.right - clippingClientRect.right + paddingObject.right) / offsetScale.x
  };
}
var arrow = (options) => ({
  name: "arrow",
  options,
  async fn(state) {
    const {
      x,
      y,
      placement,
      rects,
      platform: platform2,
      elements,
      middlewareData
    } = state;
    const {
      element,
      padding = 0
    } = evaluate(options, state) || {};
    if (element == null) {
      return {};
    }
    const paddingObject = getPaddingObject(padding);
    const coords = {
      x,
      y
    };
    const axis = getAlignmentAxis(placement);
    const length = getAxisLength(axis);
    const arrowDimensions = await platform2.getDimensions(element);
    const isYAxis = axis === "y";
    const minProp = isYAxis ? "top" : "left";
    const maxProp = isYAxis ? "bottom" : "right";
    const clientProp = isYAxis ? "clientHeight" : "clientWidth";
    const endDiff = rects.reference[length] + rects.reference[axis] - coords[axis] - rects.floating[length];
    const startDiff = coords[axis] - rects.reference[axis];
    const arrowOffsetParent = await (platform2.getOffsetParent == null ? void 0 : platform2.getOffsetParent(element));
    let clientSize = arrowOffsetParent ? arrowOffsetParent[clientProp] : 0;
    if (!clientSize || !await (platform2.isElement == null ? void 0 : platform2.isElement(arrowOffsetParent))) {
      clientSize = elements.floating[clientProp] || rects.floating[length];
    }
    const centerToReference = endDiff / 2 - startDiff / 2;
    const largestPossiblePadding = clientSize / 2 - arrowDimensions[length] / 2 - 1;
    const minPadding = min(paddingObject[minProp], largestPossiblePadding);
    const maxPadding = min(paddingObject[maxProp], largestPossiblePadding);
    const min$1 = minPadding;
    const max3 = clientSize - arrowDimensions[length] - maxPadding;
    const center = clientSize / 2 - arrowDimensions[length] / 2 + centerToReference;
    const offset3 = clamp(min$1, center, max3);
    const shouldAddOffset = !middlewareData.arrow && getAlignment(placement) != null && center !== offset3 && rects.reference[length] / 2 - (center < min$1 ? minPadding : maxPadding) - arrowDimensions[length] / 2 < 0;
    const alignmentOffset = shouldAddOffset ? center < min$1 ? center - min$1 : center - max3 : 0;
    return {
      [axis]: coords[axis] + alignmentOffset,
      data: {
        [axis]: offset3,
        centerOffset: center - offset3 - alignmentOffset,
        ...shouldAddOffset && {
          alignmentOffset
        }
      },
      reset: shouldAddOffset
    };
  }
});
var flip = function(options) {
  if (options === void 0) {
    options = {};
  }
  return {
    name: "flip",
    options,
    async fn(state) {
      var _middlewareData$arrow, _middlewareData$flip;
      const {
        placement,
        middlewareData,
        rects,
        initialPlacement,
        platform: platform2,
        elements
      } = state;
      const {
        mainAxis: checkMainAxis = true,
        crossAxis: checkCrossAxis = true,
        fallbackPlacements: specifiedFallbackPlacements,
        fallbackStrategy = "bestFit",
        fallbackAxisSideDirection = "none",
        flipAlignment = true,
        ...detectOverflowOptions
      } = evaluate(options, state);
      if ((_middlewareData$arrow = middlewareData.arrow) != null && _middlewareData$arrow.alignmentOffset) {
        return {};
      }
      const side = getSide(placement);
      const initialSideAxis = getSideAxis(initialPlacement);
      const isBasePlacement = getSide(initialPlacement) === initialPlacement;
      const rtl = await (platform2.isRTL == null ? void 0 : platform2.isRTL(elements.floating));
      const fallbackPlacements = specifiedFallbackPlacements || (isBasePlacement || !flipAlignment ? [getOppositePlacement(initialPlacement)] : getExpandedPlacements(initialPlacement));
      const hasFallbackAxisSideDirection = fallbackAxisSideDirection !== "none";
      if (!specifiedFallbackPlacements && hasFallbackAxisSideDirection) {
        fallbackPlacements.push(...getOppositeAxisPlacements(initialPlacement, flipAlignment, fallbackAxisSideDirection, rtl));
      }
      const placements2 = [initialPlacement, ...fallbackPlacements];
      const overflow = await detectOverflow(state, detectOverflowOptions);
      const overflows = [];
      let overflowsData = ((_middlewareData$flip = middlewareData.flip) == null ? void 0 : _middlewareData$flip.overflows) || [];
      if (checkMainAxis) {
        overflows.push(overflow[side]);
      }
      if (checkCrossAxis) {
        const sides2 = getAlignmentSides(placement, rects, rtl);
        overflows.push(overflow[sides2[0]], overflow[sides2[1]]);
      }
      overflowsData = [...overflowsData, {
        placement,
        overflows
      }];
      if (!overflows.every((side2) => side2 <= 0)) {
        var _middlewareData$flip2, _overflowsData$filter;
        const nextIndex = (((_middlewareData$flip2 = middlewareData.flip) == null ? void 0 : _middlewareData$flip2.index) || 0) + 1;
        const nextPlacement = placements2[nextIndex];
        if (nextPlacement) {
          const ignoreCrossAxisOverflow = checkCrossAxis === "alignment" ? initialSideAxis !== getSideAxis(nextPlacement) : false;
          if (!ignoreCrossAxisOverflow || // We leave the current main axis only if every placement on that axis
          // overflows the main axis.
          overflowsData.every((d) => getSideAxis(d.placement) === initialSideAxis ? d.overflows[0] > 0 : true)) {
            return {
              data: {
                index: nextIndex,
                overflows: overflowsData
              },
              reset: {
                placement: nextPlacement
              }
            };
          }
        }
        let resetPlacement = (_overflowsData$filter = overflowsData.filter((d) => d.overflows[0] <= 0).sort((a, b) => a.overflows[1] - b.overflows[1])[0]) == null ? void 0 : _overflowsData$filter.placement;
        if (!resetPlacement) {
          switch (fallbackStrategy) {
            case "bestFit": {
              var _overflowsData$filter2;
              const placement2 = (_overflowsData$filter2 = overflowsData.filter((d) => {
                if (hasFallbackAxisSideDirection) {
                  const currentSideAxis = getSideAxis(d.placement);
                  return currentSideAxis === initialSideAxis || // Create a bias to the `y` side axis due to horizontal
                  // reading directions favoring greater width.
                  currentSideAxis === "y";
                }
                return true;
              }).map((d) => [d.placement, d.overflows.filter((overflow2) => overflow2 > 0).reduce((acc, overflow2) => acc + overflow2, 0)]).sort((a, b) => a[1] - b[1])[0]) == null ? void 0 : _overflowsData$filter2[0];
              if (placement2) {
                resetPlacement = placement2;
              }
              break;
            }
            case "initialPlacement":
              resetPlacement = initialPlacement;
              break;
          }
        }
        if (placement !== resetPlacement) {
          return {
            reset: {
              placement: resetPlacement
            }
          };
        }
      }
      return {};
    }
  };
};
function getSideOffsets(overflow, rect2) {
  return {
    top: overflow.top - rect2.height,
    right: overflow.right - rect2.width,
    bottom: overflow.bottom - rect2.height,
    left: overflow.left - rect2.width
  };
}
function isAnySideFullyClipped(overflow) {
  return sides.some((side) => overflow[side] >= 0);
}
var hide = function(options) {
  if (options === void 0) {
    options = {};
  }
  return {
    name: "hide",
    options,
    async fn(state) {
      const {
        rects
      } = state;
      const {
        strategy = "referenceHidden",
        ...detectOverflowOptions
      } = evaluate(options, state);
      switch (strategy) {
        case "referenceHidden": {
          const overflow = await detectOverflow(state, {
            ...detectOverflowOptions,
            elementContext: "reference"
          });
          const offsets = getSideOffsets(overflow, rects.reference);
          return {
            data: {
              referenceHiddenOffsets: offsets,
              referenceHidden: isAnySideFullyClipped(offsets)
            }
          };
        }
        case "escaped": {
          const overflow = await detectOverflow(state, {
            ...detectOverflowOptions,
            altBoundary: true
          });
          const offsets = getSideOffsets(overflow, rects.floating);
          return {
            data: {
              escapedOffsets: offsets,
              escaped: isAnySideFullyClipped(offsets)
            }
          };
        }
        default: {
          return {};
        }
      }
    }
  };
};
var originSides = /* @__PURE__ */ new Set(["left", "top"]);
async function convertValueToCoords(state, options) {
  const {
    placement,
    platform: platform2,
    elements
  } = state;
  const rtl = await (platform2.isRTL == null ? void 0 : platform2.isRTL(elements.floating));
  const side = getSide(placement);
  const alignment = getAlignment(placement);
  const isVertical = getSideAxis(placement) === "y";
  const mainAxisMulti = originSides.has(side) ? -1 : 1;
  const crossAxisMulti = rtl && isVertical ? -1 : 1;
  const rawValue = evaluate(options, state);
  let {
    mainAxis,
    crossAxis,
    alignmentAxis
  } = typeof rawValue === "number" ? {
    mainAxis: rawValue,
    crossAxis: 0,
    alignmentAxis: null
  } : {
    mainAxis: rawValue.mainAxis || 0,
    crossAxis: rawValue.crossAxis || 0,
    alignmentAxis: rawValue.alignmentAxis
  };
  if (alignment && typeof alignmentAxis === "number") {
    crossAxis = alignment === "end" ? alignmentAxis * -1 : alignmentAxis;
  }
  return isVertical ? {
    x: crossAxis * crossAxisMulti,
    y: mainAxis * mainAxisMulti
  } : {
    x: mainAxis * mainAxisMulti,
    y: crossAxis * crossAxisMulti
  };
}
var offset = function(options) {
  if (options === void 0) {
    options = 0;
  }
  return {
    name: "offset",
    options,
    async fn(state) {
      var _middlewareData$offse, _middlewareData$arrow;
      const {
        x,
        y,
        placement,
        middlewareData
      } = state;
      const diffCoords = await convertValueToCoords(state, options);
      if (placement === ((_middlewareData$offse = middlewareData.offset) == null ? void 0 : _middlewareData$offse.placement) && (_middlewareData$arrow = middlewareData.arrow) != null && _middlewareData$arrow.alignmentOffset) {
        return {};
      }
      return {
        x: x + diffCoords.x,
        y: y + diffCoords.y,
        data: {
          ...diffCoords,
          placement
        }
      };
    }
  };
};
var shift = function(options) {
  if (options === void 0) {
    options = {};
  }
  return {
    name: "shift",
    options,
    async fn(state) {
      const {
        x,
        y,
        placement
      } = state;
      const {
        mainAxis: checkMainAxis = true,
        crossAxis: checkCrossAxis = false,
        limiter = {
          fn: (_ref) => {
            let {
              x: x2,
              y: y2
            } = _ref;
            return {
              x: x2,
              y: y2
            };
          }
        },
        ...detectOverflowOptions
      } = evaluate(options, state);
      const coords = {
        x,
        y
      };
      const overflow = await detectOverflow(state, detectOverflowOptions);
      const crossAxis = getSideAxis(getSide(placement));
      const mainAxis = getOppositeAxis(crossAxis);
      let mainAxisCoord = coords[mainAxis];
      let crossAxisCoord = coords[crossAxis];
      if (checkMainAxis) {
        const minSide = mainAxis === "y" ? "top" : "left";
        const maxSide = mainAxis === "y" ? "bottom" : "right";
        const min3 = mainAxisCoord + overflow[minSide];
        const max3 = mainAxisCoord - overflow[maxSide];
        mainAxisCoord = clamp(min3, mainAxisCoord, max3);
      }
      if (checkCrossAxis) {
        const minSide = crossAxis === "y" ? "top" : "left";
        const maxSide = crossAxis === "y" ? "bottom" : "right";
        const min3 = crossAxisCoord + overflow[minSide];
        const max3 = crossAxisCoord - overflow[maxSide];
        crossAxisCoord = clamp(min3, crossAxisCoord, max3);
      }
      const limitedCoords = limiter.fn({
        ...state,
        [mainAxis]: mainAxisCoord,
        [crossAxis]: crossAxisCoord
      });
      return {
        ...limitedCoords,
        data: {
          x: limitedCoords.x - x,
          y: limitedCoords.y - y,
          enabled: {
            [mainAxis]: checkMainAxis,
            [crossAxis]: checkCrossAxis
          }
        }
      };
    }
  };
};
var size = function(options) {
  if (options === void 0) {
    options = {};
  }
  return {
    name: "size",
    options,
    async fn(state) {
      var _state$middlewareData, _state$middlewareData2;
      const {
        placement,
        rects,
        platform: platform2,
        elements
      } = state;
      const {
        apply = () => {
        },
        ...detectOverflowOptions
      } = evaluate(options, state);
      const overflow = await detectOverflow(state, detectOverflowOptions);
      const side = getSide(placement);
      const alignment = getAlignment(placement);
      const isYAxis = getSideAxis(placement) === "y";
      const {
        width,
        height
      } = rects.floating;
      let heightSide;
      let widthSide;
      if (side === "top" || side === "bottom") {
        heightSide = side;
        widthSide = alignment === (await (platform2.isRTL == null ? void 0 : platform2.isRTL(elements.floating)) ? "start" : "end") ? "left" : "right";
      } else {
        widthSide = side;
        heightSide = alignment === "end" ? "top" : "bottom";
      }
      const maximumClippingHeight = height - overflow.top - overflow.bottom;
      const maximumClippingWidth = width - overflow.left - overflow.right;
      const overflowAvailableHeight = min(height - overflow[heightSide], maximumClippingHeight);
      const overflowAvailableWidth = min(width - overflow[widthSide], maximumClippingWidth);
      const noShift = !state.middlewareData.shift;
      let availableHeight = overflowAvailableHeight;
      let availableWidth = overflowAvailableWidth;
      if ((_state$middlewareData = state.middlewareData.shift) != null && _state$middlewareData.enabled.x) {
        availableWidth = maximumClippingWidth;
      }
      if ((_state$middlewareData2 = state.middlewareData.shift) != null && _state$middlewareData2.enabled.y) {
        availableHeight = maximumClippingHeight;
      }
      if (noShift && !alignment) {
        const xMin = max(overflow.left, 0);
        const xMax = max(overflow.right, 0);
        const yMin = max(overflow.top, 0);
        const yMax = max(overflow.bottom, 0);
        if (isYAxis) {
          availableWidth = width - 2 * (xMin !== 0 || xMax !== 0 ? xMin + xMax : max(overflow.left, overflow.right));
        } else {
          availableHeight = height - 2 * (yMin !== 0 || yMax !== 0 ? yMin + yMax : max(overflow.top, overflow.bottom));
        }
      }
      await apply({
        ...state,
        availableWidth,
        availableHeight
      });
      const nextDimensions = await platform2.getDimensions(elements.floating);
      if (width !== nextDimensions.width || height !== nextDimensions.height) {
        return {
          reset: {
            rects: true
          }
        };
      }
      return {};
    }
  };
};

// node_modules/@floating-ui/utils/dist/floating-ui.utils.dom.mjs
function hasWindow() {
  return typeof window !== "undefined";
}
function getNodeName(node) {
  if (isNode(node)) {
    return (node.nodeName || "").toLowerCase();
  }
  return "#document";
}
function getWindow(node) {
  var _node$ownerDocument;
  return (node == null || (_node$ownerDocument = node.ownerDocument) == null ? void 0 : _node$ownerDocument.defaultView) || window;
}
function getDocumentElement(node) {
  var _ref;
  return (_ref = (isNode(node) ? node.ownerDocument : node.document) || window.document) == null ? void 0 : _ref.documentElement;
}
function isNode(value) {
  if (!hasWindow()) {
    return false;
  }
  return value instanceof Node || value instanceof getWindow(value).Node;
}
function isElement(value) {
  if (!hasWindow()) {
    return false;
  }
  return value instanceof Element || value instanceof getWindow(value).Element;
}
function isHTMLElement(value) {
  if (!hasWindow()) {
    return false;
  }
  return value instanceof HTMLElement || value instanceof getWindow(value).HTMLElement;
}
function isShadowRoot(value) {
  if (!hasWindow() || typeof ShadowRoot === "undefined") {
    return false;
  }
  return value instanceof ShadowRoot || value instanceof getWindow(value).ShadowRoot;
}
var invalidOverflowDisplayValues = /* @__PURE__ */ new Set(["inline", "contents"]);
function isOverflowElement(element) {
  const {
    overflow,
    overflowX,
    overflowY,
    display
  } = getComputedStyle2(element);
  return /auto|scroll|overlay|hidden|clip/.test(overflow + overflowY + overflowX) && !invalidOverflowDisplayValues.has(display);
}
var tableElements = /* @__PURE__ */ new Set(["table", "td", "th"]);
function isTableElement(element) {
  return tableElements.has(getNodeName(element));
}
var topLayerSelectors = [":popover-open", ":modal"];
function isTopLayer(element) {
  return topLayerSelectors.some((selector) => {
    try {
      return element.matches(selector);
    } catch (_e) {
      return false;
    }
  });
}
var transformProperties = ["transform", "translate", "scale", "rotate", "perspective"];
var willChangeValues = ["transform", "translate", "scale", "rotate", "perspective", "filter"];
var containValues = ["paint", "layout", "strict", "content"];
function isContainingBlock(elementOrCss) {
  const webkit = isWebKit();
  const css = isElement(elementOrCss) ? getComputedStyle2(elementOrCss) : elementOrCss;
  return transformProperties.some((value) => css[value] ? css[value] !== "none" : false) || (css.containerType ? css.containerType !== "normal" : false) || !webkit && (css.backdropFilter ? css.backdropFilter !== "none" : false) || !webkit && (css.filter ? css.filter !== "none" : false) || willChangeValues.some((value) => (css.willChange || "").includes(value)) || containValues.some((value) => (css.contain || "").includes(value));
}
function getContainingBlock(element) {
  let currentNode = getParentNode(element);
  while (isHTMLElement(currentNode) && !isLastTraversableNode(currentNode)) {
    if (isContainingBlock(currentNode)) {
      return currentNode;
    } else if (isTopLayer(currentNode)) {
      return null;
    }
    currentNode = getParentNode(currentNode);
  }
  return null;
}
function isWebKit() {
  if (typeof CSS === "undefined" || !CSS.supports) return false;
  return CSS.supports("-webkit-backdrop-filter", "none");
}
var lastTraversableNodeNames = /* @__PURE__ */ new Set(["html", "body", "#document"]);
function isLastTraversableNode(node) {
  return lastTraversableNodeNames.has(getNodeName(node));
}
function getComputedStyle2(element) {
  return getWindow(element).getComputedStyle(element);
}
function getNodeScroll(element) {
  if (isElement(element)) {
    return {
      scrollLeft: element.scrollLeft,
      scrollTop: element.scrollTop
    };
  }
  return {
    scrollLeft: element.scrollX,
    scrollTop: element.scrollY
  };
}
function getParentNode(node) {
  if (getNodeName(node) === "html") {
    return node;
  }
  const result = (
    // Step into the shadow DOM of the parent of a slotted node.
    node.assignedSlot || // DOM Element detected.
    node.parentNode || // ShadowRoot detected.
    isShadowRoot(node) && node.host || // Fallback.
    getDocumentElement(node)
  );
  return isShadowRoot(result) ? result.host : result;
}
function getNearestOverflowAncestor(node) {
  const parentNode = getParentNode(node);
  if (isLastTraversableNode(parentNode)) {
    return node.ownerDocument ? node.ownerDocument.body : node.body;
  }
  if (isHTMLElement(parentNode) && isOverflowElement(parentNode)) {
    return parentNode;
  }
  return getNearestOverflowAncestor(parentNode);
}
function getOverflowAncestors(node, list, traverseIframes) {
  var _node$ownerDocument2;
  if (list === void 0) {
    list = [];
  }
  if (traverseIframes === void 0) {
    traverseIframes = true;
  }
  const scrollableAncestor = getNearestOverflowAncestor(node);
  const isBody = scrollableAncestor === ((_node$ownerDocument2 = node.ownerDocument) == null ? void 0 : _node$ownerDocument2.body);
  const win2 = getWindow(scrollableAncestor);
  if (isBody) {
    const frameElement = getFrameElement(win2);
    return list.concat(win2, win2.visualViewport || [], isOverflowElement(scrollableAncestor) ? scrollableAncestor : [], frameElement && traverseIframes ? getOverflowAncestors(frameElement) : []);
  }
  return list.concat(scrollableAncestor, getOverflowAncestors(scrollableAncestor, [], traverseIframes));
}
function getFrameElement(win2) {
  return win2.parent && Object.getPrototypeOf(win2.parent) ? win2.frameElement : null;
}

// node_modules/@floating-ui/dom/dist/floating-ui.dom.esm.js
function getCssDimensions(element) {
  const css = getComputedStyle2(element);
  let width = parseFloat(css.width) || 0;
  let height = parseFloat(css.height) || 0;
  const hasOffset = isHTMLElement(element);
  const offsetWidth = hasOffset ? element.offsetWidth : width;
  const offsetHeight = hasOffset ? element.offsetHeight : height;
  const shouldFallback = round(width) !== offsetWidth || round(height) !== offsetHeight;
  if (shouldFallback) {
    width = offsetWidth;
    height = offsetHeight;
  }
  return {
    width,
    height,
    $: shouldFallback
  };
}
function unwrapElement(element) {
  return !isElement(element) ? element.contextElement : element;
}
function getScale(element) {
  const domElement = unwrapElement(element);
  if (!isHTMLElement(domElement)) {
    return createCoords(1);
  }
  const rect2 = domElement.getBoundingClientRect();
  const {
    width,
    height,
    $
  } = getCssDimensions(domElement);
  let x = ($ ? round(rect2.width) : rect2.width) / width;
  let y = ($ ? round(rect2.height) : rect2.height) / height;
  if (!x || !Number.isFinite(x)) {
    x = 1;
  }
  if (!y || !Number.isFinite(y)) {
    y = 1;
  }
  return {
    x,
    y
  };
}
var noOffsets = /* @__PURE__ */ createCoords(0);
function getVisualOffsets(element) {
  const win2 = getWindow(element);
  if (!isWebKit() || !win2.visualViewport) {
    return noOffsets;
  }
  return {
    x: win2.visualViewport.offsetLeft,
    y: win2.visualViewport.offsetTop
  };
}
function shouldAddVisualOffsets(element, isFixed, floatingOffsetParent) {
  if (isFixed === void 0) {
    isFixed = false;
  }
  if (!floatingOffsetParent || isFixed && floatingOffsetParent !== getWindow(element)) {
    return false;
  }
  return isFixed;
}
function getBoundingClientRect(element, includeScale, isFixedStrategy, offsetParent) {
  if (includeScale === void 0) {
    includeScale = false;
  }
  if (isFixedStrategy === void 0) {
    isFixedStrategy = false;
  }
  const clientRect = element.getBoundingClientRect();
  const domElement = unwrapElement(element);
  let scale = createCoords(1);
  if (includeScale) {
    if (offsetParent) {
      if (isElement(offsetParent)) {
        scale = getScale(offsetParent);
      }
    } else {
      scale = getScale(element);
    }
  }
  const visualOffsets = shouldAddVisualOffsets(domElement, isFixedStrategy, offsetParent) ? getVisualOffsets(domElement) : createCoords(0);
  let x = (clientRect.left + visualOffsets.x) / scale.x;
  let y = (clientRect.top + visualOffsets.y) / scale.y;
  let width = clientRect.width / scale.x;
  let height = clientRect.height / scale.y;
  if (domElement) {
    const win2 = getWindow(domElement);
    const offsetWin = offsetParent && isElement(offsetParent) ? getWindow(offsetParent) : offsetParent;
    let currentWin = win2;
    let currentIFrame = getFrameElement(currentWin);
    while (currentIFrame && offsetParent && offsetWin !== currentWin) {
      const iframeScale = getScale(currentIFrame);
      const iframeRect = currentIFrame.getBoundingClientRect();
      const css = getComputedStyle2(currentIFrame);
      const left = iframeRect.left + (currentIFrame.clientLeft + parseFloat(css.paddingLeft)) * iframeScale.x;
      const top = iframeRect.top + (currentIFrame.clientTop + parseFloat(css.paddingTop)) * iframeScale.y;
      x *= iframeScale.x;
      y *= iframeScale.y;
      width *= iframeScale.x;
      height *= iframeScale.y;
      x += left;
      y += top;
      currentWin = getWindow(currentIFrame);
      currentIFrame = getFrameElement(currentWin);
    }
  }
  return rectToClientRect({
    width,
    height,
    x,
    y
  });
}
function getWindowScrollBarX(element, rect2) {
  const leftScroll = getNodeScroll(element).scrollLeft;
  if (!rect2) {
    return getBoundingClientRect(getDocumentElement(element)).left + leftScroll;
  }
  return rect2.left + leftScroll;
}
function getHTMLOffset(documentElement, scroll2) {
  const htmlRect = documentElement.getBoundingClientRect();
  const x = htmlRect.left + scroll2.scrollLeft - getWindowScrollBarX(documentElement, htmlRect);
  const y = htmlRect.top + scroll2.scrollTop;
  return {
    x,
    y
  };
}
function convertOffsetParentRelativeRectToViewportRelativeRect(_ref) {
  let {
    elements,
    rect: rect2,
    offsetParent,
    strategy
  } = _ref;
  const isFixed = strategy === "fixed";
  const documentElement = getDocumentElement(offsetParent);
  const topLayer = elements ? isTopLayer(elements.floating) : false;
  if (offsetParent === documentElement || topLayer && isFixed) {
    return rect2;
  }
  let scroll2 = {
    scrollLeft: 0,
    scrollTop: 0
  };
  let scale = createCoords(1);
  const offsets = createCoords(0);
  const isOffsetParentAnElement = isHTMLElement(offsetParent);
  if (isOffsetParentAnElement || !isOffsetParentAnElement && !isFixed) {
    if (getNodeName(offsetParent) !== "body" || isOverflowElement(documentElement)) {
      scroll2 = getNodeScroll(offsetParent);
    }
    if (isHTMLElement(offsetParent)) {
      const offsetRect = getBoundingClientRect(offsetParent);
      scale = getScale(offsetParent);
      offsets.x = offsetRect.x + offsetParent.clientLeft;
      offsets.y = offsetRect.y + offsetParent.clientTop;
    }
  }
  const htmlOffset = documentElement && !isOffsetParentAnElement && !isFixed ? getHTMLOffset(documentElement, scroll2) : createCoords(0);
  return {
    width: rect2.width * scale.x,
    height: rect2.height * scale.y,
    x: rect2.x * scale.x - scroll2.scrollLeft * scale.x + offsets.x + htmlOffset.x,
    y: rect2.y * scale.y - scroll2.scrollTop * scale.y + offsets.y + htmlOffset.y
  };
}
function getClientRects(element) {
  return Array.from(element.getClientRects());
}
function getDocumentRect(element) {
  const html = getDocumentElement(element);
  const scroll2 = getNodeScroll(element);
  const body = element.ownerDocument.body;
  const width = max(html.scrollWidth, html.clientWidth, body.scrollWidth, body.clientWidth);
  const height = max(html.scrollHeight, html.clientHeight, body.scrollHeight, body.clientHeight);
  let x = -scroll2.scrollLeft + getWindowScrollBarX(element);
  const y = -scroll2.scrollTop;
  if (getComputedStyle2(body).direction === "rtl") {
    x += max(html.clientWidth, body.clientWidth) - width;
  }
  return {
    width,
    height,
    x,
    y
  };
}
var SCROLLBAR_MAX = 25;
function getViewportRect(element, strategy) {
  const win2 = getWindow(element);
  const html = getDocumentElement(element);
  const visualViewport = win2.visualViewport;
  let width = html.clientWidth;
  let height = html.clientHeight;
  let x = 0;
  let y = 0;
  if (visualViewport) {
    width = visualViewport.width;
    height = visualViewport.height;
    const visualViewportBased = isWebKit();
    if (!visualViewportBased || visualViewportBased && strategy === "fixed") {
      x = visualViewport.offsetLeft;
      y = visualViewport.offsetTop;
    }
  }
  const windowScrollbarX = getWindowScrollBarX(html);
  if (windowScrollbarX <= 0) {
    const doc2 = html.ownerDocument;
    const body = doc2.body;
    const bodyStyles = getComputedStyle(body);
    const bodyMarginInline = doc2.compatMode === "CSS1Compat" ? parseFloat(bodyStyles.marginLeft) + parseFloat(bodyStyles.marginRight) || 0 : 0;
    const clippingStableScrollbarWidth = Math.abs(html.clientWidth - body.clientWidth - bodyMarginInline);
    if (clippingStableScrollbarWidth <= SCROLLBAR_MAX) {
      width -= clippingStableScrollbarWidth;
    }
  } else if (windowScrollbarX <= SCROLLBAR_MAX) {
    width += windowScrollbarX;
  }
  return {
    width,
    height,
    x,
    y
  };
}
var absoluteOrFixed = /* @__PURE__ */ new Set(["absolute", "fixed"]);
function getInnerBoundingClientRect(element, strategy) {
  const clientRect = getBoundingClientRect(element, true, strategy === "fixed");
  const top = clientRect.top + element.clientTop;
  const left = clientRect.left + element.clientLeft;
  const scale = isHTMLElement(element) ? getScale(element) : createCoords(1);
  const width = element.clientWidth * scale.x;
  const height = element.clientHeight * scale.y;
  const x = left * scale.x;
  const y = top * scale.y;
  return {
    width,
    height,
    x,
    y
  };
}
function getClientRectFromClippingAncestor(element, clippingAncestor, strategy) {
  let rect2;
  if (clippingAncestor === "viewport") {
    rect2 = getViewportRect(element, strategy);
  } else if (clippingAncestor === "document") {
    rect2 = getDocumentRect(getDocumentElement(element));
  } else if (isElement(clippingAncestor)) {
    rect2 = getInnerBoundingClientRect(clippingAncestor, strategy);
  } else {
    const visualOffsets = getVisualOffsets(element);
    rect2 = {
      x: clippingAncestor.x - visualOffsets.x,
      y: clippingAncestor.y - visualOffsets.y,
      width: clippingAncestor.width,
      height: clippingAncestor.height
    };
  }
  return rectToClientRect(rect2);
}
function hasFixedPositionAncestor(element, stopNode) {
  const parentNode = getParentNode(element);
  if (parentNode === stopNode || !isElement(parentNode) || isLastTraversableNode(parentNode)) {
    return false;
  }
  return getComputedStyle2(parentNode).position === "fixed" || hasFixedPositionAncestor(parentNode, stopNode);
}
function getClippingElementAncestors(element, cache) {
  const cachedResult = cache.get(element);
  if (cachedResult) {
    return cachedResult;
  }
  let result = getOverflowAncestors(element, [], false).filter((el) => isElement(el) && getNodeName(el) !== "body");
  let currentContainingBlockComputedStyle = null;
  const elementIsFixed = getComputedStyle2(element).position === "fixed";
  let currentNode = elementIsFixed ? getParentNode(element) : element;
  while (isElement(currentNode) && !isLastTraversableNode(currentNode)) {
    const computedStyle = getComputedStyle2(currentNode);
    const currentNodeIsContaining = isContainingBlock(currentNode);
    if (!currentNodeIsContaining && computedStyle.position === "fixed") {
      currentContainingBlockComputedStyle = null;
    }
    const shouldDropCurrentNode = elementIsFixed ? !currentNodeIsContaining && !currentContainingBlockComputedStyle : !currentNodeIsContaining && computedStyle.position === "static" && !!currentContainingBlockComputedStyle && absoluteOrFixed.has(currentContainingBlockComputedStyle.position) || isOverflowElement(currentNode) && !currentNodeIsContaining && hasFixedPositionAncestor(element, currentNode);
    if (shouldDropCurrentNode) {
      result = result.filter((ancestor) => ancestor !== currentNode);
    } else {
      currentContainingBlockComputedStyle = computedStyle;
    }
    currentNode = getParentNode(currentNode);
  }
  cache.set(element, result);
  return result;
}
function getClippingRect(_ref) {
  let {
    element,
    boundary,
    rootBoundary,
    strategy
  } = _ref;
  const elementClippingAncestors = boundary === "clippingAncestors" ? isTopLayer(element) ? [] : getClippingElementAncestors(element, this._c) : [].concat(boundary);
  const clippingAncestors = [...elementClippingAncestors, rootBoundary];
  const firstClippingAncestor = clippingAncestors[0];
  const clippingRect = clippingAncestors.reduce((accRect, clippingAncestor) => {
    const rect2 = getClientRectFromClippingAncestor(element, clippingAncestor, strategy);
    accRect.top = max(rect2.top, accRect.top);
    accRect.right = min(rect2.right, accRect.right);
    accRect.bottom = min(rect2.bottom, accRect.bottom);
    accRect.left = max(rect2.left, accRect.left);
    return accRect;
  }, getClientRectFromClippingAncestor(element, firstClippingAncestor, strategy));
  return {
    width: clippingRect.right - clippingRect.left,
    height: clippingRect.bottom - clippingRect.top,
    x: clippingRect.left,
    y: clippingRect.top
  };
}
function getDimensions(element) {
  const {
    width,
    height
  } = getCssDimensions(element);
  return {
    width,
    height
  };
}
function getRectRelativeToOffsetParent(element, offsetParent, strategy) {
  const isOffsetParentAnElement = isHTMLElement(offsetParent);
  const documentElement = getDocumentElement(offsetParent);
  const isFixed = strategy === "fixed";
  const rect2 = getBoundingClientRect(element, true, isFixed, offsetParent);
  let scroll2 = {
    scrollLeft: 0,
    scrollTop: 0
  };
  const offsets = createCoords(0);
  function setLeftRTLScrollbarOffset() {
    offsets.x = getWindowScrollBarX(documentElement);
  }
  if (isOffsetParentAnElement || !isOffsetParentAnElement && !isFixed) {
    if (getNodeName(offsetParent) !== "body" || isOverflowElement(documentElement)) {
      scroll2 = getNodeScroll(offsetParent);
    }
    if (isOffsetParentAnElement) {
      const offsetRect = getBoundingClientRect(offsetParent, true, isFixed, offsetParent);
      offsets.x = offsetRect.x + offsetParent.clientLeft;
      offsets.y = offsetRect.y + offsetParent.clientTop;
    } else if (documentElement) {
      setLeftRTLScrollbarOffset();
    }
  }
  if (isFixed && !isOffsetParentAnElement && documentElement) {
    setLeftRTLScrollbarOffset();
  }
  const htmlOffset = documentElement && !isOffsetParentAnElement && !isFixed ? getHTMLOffset(documentElement, scroll2) : createCoords(0);
  const x = rect2.left + scroll2.scrollLeft - offsets.x - htmlOffset.x;
  const y = rect2.top + scroll2.scrollTop - offsets.y - htmlOffset.y;
  return {
    x,
    y,
    width: rect2.width,
    height: rect2.height
  };
}
function isStaticPositioned(element) {
  return getComputedStyle2(element).position === "static";
}
function getTrueOffsetParent(element, polyfill) {
  if (!isHTMLElement(element) || getComputedStyle2(element).position === "fixed") {
    return null;
  }
  if (polyfill) {
    return polyfill(element);
  }
  let rawOffsetParent = element.offsetParent;
  if (getDocumentElement(element) === rawOffsetParent) {
    rawOffsetParent = rawOffsetParent.ownerDocument.body;
  }
  return rawOffsetParent;
}
function getOffsetParent(element, polyfill) {
  const win2 = getWindow(element);
  if (isTopLayer(element)) {
    return win2;
  }
  if (!isHTMLElement(element)) {
    let svgOffsetParent = getParentNode(element);
    while (svgOffsetParent && !isLastTraversableNode(svgOffsetParent)) {
      if (isElement(svgOffsetParent) && !isStaticPositioned(svgOffsetParent)) {
        return svgOffsetParent;
      }
      svgOffsetParent = getParentNode(svgOffsetParent);
    }
    return win2;
  }
  let offsetParent = getTrueOffsetParent(element, polyfill);
  while (offsetParent && isTableElement(offsetParent) && isStaticPositioned(offsetParent)) {
    offsetParent = getTrueOffsetParent(offsetParent, polyfill);
  }
  if (offsetParent && isLastTraversableNode(offsetParent) && isStaticPositioned(offsetParent) && !isContainingBlock(offsetParent)) {
    return win2;
  }
  return offsetParent || getContainingBlock(element) || win2;
}
var getElementRects = async function(data) {
  const getOffsetParentFn = this.getOffsetParent || getOffsetParent;
  const getDimensionsFn = this.getDimensions;
  const floatingDimensions = await getDimensionsFn(data.floating);
  return {
    reference: getRectRelativeToOffsetParent(data.reference, await getOffsetParentFn(data.floating), data.strategy),
    floating: {
      x: 0,
      y: 0,
      width: floatingDimensions.width,
      height: floatingDimensions.height
    }
  };
};
function isRTL(element) {
  return getComputedStyle2(element).direction === "rtl";
}
var platform = {
  convertOffsetParentRelativeRectToViewportRelativeRect,
  getDocumentElement,
  getClippingRect,
  getOffsetParent,
  getElementRects,
  getClientRects,
  getDimensions,
  getScale,
  isElement,
  isRTL
};
function rectsAreEqual(a, b) {
  return a.x === b.x && a.y === b.y && a.width === b.width && a.height === b.height;
}
function observeMove(element, onMove) {
  let io = null;
  let timeoutId;
  const root = getDocumentElement(element);
  function cleanup() {
    var _io;
    clearTimeout(timeoutId);
    (_io = io) == null || _io.disconnect();
    io = null;
  }
  function refresh(skip, threshold) {
    if (skip === void 0) {
      skip = false;
    }
    if (threshold === void 0) {
      threshold = 1;
    }
    cleanup();
    const elementRectForRootMargin = element.getBoundingClientRect();
    const {
      left,
      top,
      width,
      height
    } = elementRectForRootMargin;
    if (!skip) {
      onMove();
    }
    if (!width || !height) {
      return;
    }
    const insetTop = floor(top);
    const insetRight = floor(root.clientWidth - (left + width));
    const insetBottom = floor(root.clientHeight - (top + height));
    const insetLeft = floor(left);
    const rootMargin = -insetTop + "px " + -insetRight + "px " + -insetBottom + "px " + -insetLeft + "px";
    const options = {
      rootMargin,
      threshold: max(0, min(1, threshold)) || 1
    };
    let isFirstUpdate = true;
    function handleObserve(entries) {
      const ratio = entries[0].intersectionRatio;
      if (ratio !== threshold) {
        if (!isFirstUpdate) {
          return refresh();
        }
        if (!ratio) {
          timeoutId = setTimeout(() => {
            refresh(false, 1e-7);
          }, 1e3);
        } else {
          refresh(false, ratio);
        }
      }
      if (ratio === 1 && !rectsAreEqual(elementRectForRootMargin, element.getBoundingClientRect())) {
        refresh();
      }
      isFirstUpdate = false;
    }
    try {
      io = new IntersectionObserver(handleObserve, {
        ...options,
        // Handle <iframe>s
        root: root.ownerDocument
      });
    } catch (_e) {
      io = new IntersectionObserver(handleObserve, options);
    }
    io.observe(element);
  }
  refresh(true);
  return cleanup;
}
function autoUpdate(reference, floating, update, options) {
  if (options === void 0) {
    options = {};
  }
  const {
    ancestorScroll = true,
    ancestorResize = true,
    elementResize = typeof ResizeObserver === "function",
    layoutShift = typeof IntersectionObserver === "function",
    animationFrame = false
  } = options;
  const referenceEl = unwrapElement(reference);
  const ancestors = ancestorScroll || ancestorResize ? [...referenceEl ? getOverflowAncestors(referenceEl) : [], ...getOverflowAncestors(floating)] : [];
  ancestors.forEach((ancestor) => {
    ancestorScroll && ancestor.addEventListener("scroll", update, {
      passive: true
    });
    ancestorResize && ancestor.addEventListener("resize", update);
  });
  const cleanupIo = referenceEl && layoutShift ? observeMove(referenceEl, update) : null;
  let reobserveFrame = -1;
  let resizeObserver = null;
  if (elementResize) {
    resizeObserver = new ResizeObserver((_ref) => {
      let [firstEntry] = _ref;
      if (firstEntry && firstEntry.target === referenceEl && resizeObserver) {
        resizeObserver.unobserve(floating);
        cancelAnimationFrame(reobserveFrame);
        reobserveFrame = requestAnimationFrame(() => {
          var _resizeObserver;
          (_resizeObserver = resizeObserver) == null || _resizeObserver.observe(floating);
        });
      }
      update();
    });
    if (referenceEl && !animationFrame) {
      resizeObserver.observe(referenceEl);
    }
    resizeObserver.observe(floating);
  }
  let frameId;
  let prevRefRect = animationFrame ? getBoundingClientRect(reference) : null;
  if (animationFrame) {
    frameLoop();
  }
  function frameLoop() {
    const nextRefRect = getBoundingClientRect(reference);
    if (prevRefRect && !rectsAreEqual(prevRefRect, nextRefRect)) {
      update();
    }
    prevRefRect = nextRefRect;
    frameId = requestAnimationFrame(frameLoop);
  }
  update();
  return () => {
    var _resizeObserver2;
    ancestors.forEach((ancestor) => {
      ancestorScroll && ancestor.removeEventListener("scroll", update);
      ancestorResize && ancestor.removeEventListener("resize", update);
    });
    cleanupIo == null || cleanupIo();
    (_resizeObserver2 = resizeObserver) == null || _resizeObserver2.disconnect();
    resizeObserver = null;
    if (animationFrame) {
      cancelAnimationFrame(frameId);
    }
  };
}
var offset2 = offset;
var shift2 = shift;
var flip2 = flip;
var size2 = size;
var hide2 = hide;
var arrow2 = arrow;
var computePosition2 = (reference, floating, options) => {
  const cache = /* @__PURE__ */ new Map();
  const mergedOptions = {
    platform,
    ...options
  };
  const platformWithCache = {
    ...mergedOptions.platform,
    _c: cache
  };
  return computePosition(reference, floating, {
    ...mergedOptions,
    platform: platformWithCache
  });
};

// js/popover.js
var Popover = class extends ViewHook {
  expanded = false;
  name = "popover";
  placement = "bottom-start";
  defaultPlacement = "bottom-start";
  activePlacement = "bottom-start";
  strategy = "absolute";
  // floating-ui strategy
  defaultStrategy = "absolute";
  currentStrategy = "absolute";
  event_trigger = "click";
  // "click" | "hover" | "focus"
  currentIndex = -1;
  expand_popover = false;
  // expand popover to match width of trigger
  focus_selected = true;
  #outside_listener;
  #clear_floating;
  #triggerClickHandler;
  #triggerMouseEnterHandler;
  #triggerMouseLeaveHandler;
  #triggerFocusHandler;
  #triggerBlurHandler;
  #containerKeyDownHandler;
  #triggerKeyDownHandler;
  mounted() {
    this.defaultPlacement = this.el.dataset.placement || this.placement;
    this.activePlacement = this.defaultPlacement;
    this.placement = this.defaultPlacement;
    this.strategy = this.el.dataset.strategy || this.strategy;
    this.currentStrategy = this.resolveStrategy();
    this.event_trigger = this.el.dataset.trigger || this.event_trigger;
    this.cacheElements();
    this.refreshExpanded();
    this.#triggerClickHandler = this.handleTriggerClick.bind(this);
    this.#triggerMouseEnterHandler = this.handleTriggerMouseEnter.bind(this);
    this.#triggerMouseLeaveHandler = this.handleTriggerMouseLeave.bind(this);
    this.#triggerFocusHandler = this.handleTriggerFocus.bind(this);
    this.#triggerBlurHandler = this.handleTriggerBlur.bind(this);
    this.#containerKeyDownHandler = this.handleContainerKeyDown.bind(this);
    this.#triggerKeyDownHandler = this.handleTriggerKeyDown.bind(this);
    this.bindEventListeners();
    this.#outside_listener = (event) => {
      const target = event.target;
      const clickedOnTrigger = this.trigger?.contains(target);
      const clickedOnPopup = this.popup?.contains(target);
      if (!clickedOnTrigger && !clickedOnPopup && this.expanded) {
        this.closePopover();
      }
    };
    this.initFloatingUI();
  }
  listenOutside() {
    document.addEventListener("click", this.#outside_listener);
  }
  removeOutsideListener() {
    document.removeEventListener("click", this.#outside_listener);
  }
  updated() {
    const previousTrigger = this.trigger;
    this.cacheElements();
    this.rebindEventListeners(previousTrigger);
    this.restoreExpanded();
    this.initFloatingUI();
    this.refreshFloatingUI();
  }
  destroyed() {
    this.unbindEventListeners(this.trigger);
    document.removeEventListener("click", this.#outside_listener);
    if (this.#clear_floating) {
      this.#clear_floating();
    }
  }
  handleTriggerKeyDown(event) {
    if (!this.expanded && (event.key === "ArrowDown" || event.key === "ArrowUp")) {
      event.preventDefault();
      this.openPopover({ placement: this.getPlacementForKey(event.key) });
      return;
    }
    if (!this.expanded && this.isPrintableKeyEvent(event)) {
      const handled = this.handleTriggerTypeahead(event);
      if (handled) {
        event.preventDefault();
      }
    }
  }
  handleTriggerClick() {
    if (this.expanded) {
      this.closePopover();
    } else {
      this.openPopover({ placement: this.getOpenPlacement() });
    }
    this.refreshExpanded();
  }
  handleTriggerMouseEnter() {
    this.openPopover();
    this.refreshExpanded();
  }
  handleTriggerMouseLeave() {
    this.closePopover();
    this.refreshExpanded();
  }
  handleTriggerFocus() {
    this.openPopover();
    this.refreshExpanded();
  }
  handleTriggerBlur() {
    this.closePopover();
    this.refreshExpanded();
  }
  handleContainerKeyDown(event) {
    if (!this.expanded) return;
    switch (event.key) {
      case "Escape":
        event.preventDefault();
        event.stopPropagation();
        this.closePopover();
        this.trigger?.focus();
        break;
      case "ArrowDown":
      case "ArrowUp":
      case "Home":
      case "End":
        this.handleArrowNavigation(event);
        break;
      case "Enter":
        this.handleKeyEnter(event);
        break;
      case "Tab":
        this.closePopover();
        break;
      default:
        if (this.isPrintableKeyEvent(event)) {
          const handled = this.handlePrintableKey(event);
          if (handled) {
            event.preventDefault();
          }
        }
    }
  }
  handleKeyEnter(event) {
  }
  handleTriggerTypeahead(_event) {
    return false;
  }
  handlePrintableKey(_event) {
    return false;
  }
  handleArrowNavigation(event) {
    if (!this.expanded) return;
    const visibleItems = this.getNavigableItems();
    const itemCount = visibleItems.length;
    if (itemCount === 0) return;
    event.preventDefault();
    let newIndex = this.currentIndex;
    switch (event.key) {
      case "ArrowDown":
        newIndex = (this.currentIndex + 1) % itemCount;
        break;
      case "ArrowUp":
        newIndex = (this.currentIndex - 1 + itemCount) % itemCount;
        break;
      case "Home":
        newIndex = 0;
        break;
      case "End":
        newIndex = itemCount - 1;
        break;
    }
    this.setCurrentItemByIndex(newIndex, visibleItems);
  }
  initFloatingUI() {
    if (this.#clear_floating) {
      this.#clear_floating();
    }
    if (!this.trigger || !this.popup) {
      return;
    }
    if (!this.expanded) {
      return;
    }
    this.currentStrategy = this.resolveStrategy();
    this.#clear_floating = autoUpdate(
      this.trigger,
      this.popup,
      () => {
        this.refreshFloatingUI();
      },
      {
        animationFrame: this.currentStrategy === "fixed"
      }
    );
  }
  bindEventListeners() {
    this.el.addEventListener("keydown", this.#containerKeyDownHandler);
    this.trigger?.addEventListener("keydown", this.#triggerKeyDownHandler);
    if (this.event_trigger === "click") {
      this.trigger?.addEventListener("click", this.#triggerClickHandler);
      return;
    }
    if (this.event_trigger === "hover") {
      this.trigger?.addEventListener(
        "mouseenter",
        this.#triggerMouseEnterHandler
      );
      this.trigger?.addEventListener(
        "mouseleave",
        this.#triggerMouseLeaveHandler
      );
      return;
    }
    if (this.event_trigger === "focus") {
      this.trigger?.addEventListener("focus", this.#triggerFocusHandler);
      this.trigger?.addEventListener("blur", this.#triggerBlurHandler);
    }
  }
  unbindEventListeners(trigger) {
    this.el.removeEventListener("keydown", this.#containerKeyDownHandler);
    trigger?.removeEventListener("keydown", this.#triggerKeyDownHandler);
    trigger?.removeEventListener("click", this.#triggerClickHandler);
    trigger?.removeEventListener("mouseenter", this.#triggerMouseEnterHandler);
    trigger?.removeEventListener("mouseleave", this.#triggerMouseLeaveHandler);
    trigger?.removeEventListener("focus", this.#triggerFocusHandler);
    trigger?.removeEventListener("blur", this.#triggerBlurHandler);
  }
  rebindEventListeners(previousTrigger) {
    if (previousTrigger === this.trigger) {
      return;
    }
    this.unbindEventListeners(previousTrigger);
    this.bindEventListeners();
  }
  refreshFloatingUI() {
    if (!this.trigger || !this.popup || !this.expanded) {
      return Promise.resolve();
    }
    const expand_popover = this.expand_popover;
    const collisionPadding = 8;
    const nextStrategy = this.resolveStrategy();
    if (nextStrategy !== this.currentStrategy) {
      this.currentStrategy = nextStrategy;
      this.initFloatingUI();
    } else {
      this.currentStrategy = nextStrategy;
    }
    return computePosition2(this.trigger, this.popup, {
      placement: this.activePlacement,
      strategy: this.currentStrategy,
      middleware: [
        offset2(collisionPadding),
        flip2({ padding: collisionPadding }),
        shift2({ padding: collisionPadding }),
        size2({
          padding: collisionPadding,
          apply({ rects, elements }) {
            if (expand_popover) {
              elements.floating.style.width = `${Math.max(0, Math.floor(rects.reference.width))}px`;
            } else {
              elements.floating.style.removeProperty("width");
            }
          }
        }),
        hide2({ padding: collisionPadding })
      ]
    }).then(({ x, y, strategy, placement, middlewareData }) => {
      const referenceHidden = Boolean(middlewareData.hide?.referenceHidden);
      Object.assign(this.popup.style, {
        left: `${x}px`,
        top: `${y}px`,
        position: strategy
      });
      this.popup.dataset.side = placement.split("-")[0];
      this.popup.dataset.floatingStrategy = strategy;
      this.popup.dataset.referenceHidden = String(referenceHidden);
      if (referenceHidden && this.expanded) {
        this.closePopover({ restoreFocus: false });
      }
    });
  }
  closePopover(options = {}) {
    const { restoreFocus = true } = options;
    this.trigger?.setAttribute("aria-expanded", "false");
    this.popup?.setAttribute("aria-hidden", "true");
    this.expanded = false;
    this.currentIndex = -1;
    this.activePlacement = this.defaultPlacement;
    this.onPopupClosed(restoreFocus);
    this.popup?.setAttribute("data-reference-hidden", "false");
    this.removeOutsideListener();
    this.initFloatingUI();
  }
  onPopupOpened() {
  }
  onPopupClosed(restoreFocus = true) {
    if (this.popup?.contains(document.activeElement) || this.trigger?.contains(document.activeElement)) {
      if (restoreFocus) {
        this.focusElement(this.trigger);
      } else if (typeof document.activeElement?.blur === "function") {
        document.activeElement.blur();
      }
    }
  }
  openPopover(options = {}) {
    this.activePlacement = options.placement || this.getOpenPlacement();
    this.trigger?.setAttribute("aria-expanded", "true");
    this.popup?.setAttribute("aria-hidden", "false");
    this.popup?.setAttribute("data-reference-hidden", "false");
    this.focusElement(this.popup);
    this.expanded = true;
    this.currentIndex = this.getInitialNavigationIndex(
      this.getNavigableItems()
    );
    this.onPopupOpened();
    this.listenOutside();
    this.initFloatingUI();
    this.refreshFloatingUI();
  }
  log(msg, data) {
    console.log(`${this.name}: ${msg}`, data);
  }
  refreshExpanded() {
    this.expanded = this.trigger?.getAttribute("aria-expanded") == "true";
  }
  restoreExpanded() {
    if (this.expanded) {
      this.openPopover({ placement: this.activePlacement });
    } else {
      this.closePopover();
    }
  }
  cacheElements() {
    this.trigger = this.el.querySelector("[aria-haspopup],[role='combobox']");
    this.popup = this.el.querySelector("[role='menu'],[role='listbox']");
    this.items = this.popup?.querySelectorAll("[role='option'],[role='menuitem']") ?? [];
  }
  getOpenPlacement() {
    return this.defaultPlacement;
  }
  getPlacementForKey(_key) {
    return this.defaultPlacement;
  }
  getNavigableItems() {
    return Array.from(this.items).filter(
      (item) => item.style.display !== "none" && item.getAttribute("aria-disabled") !== "true" && item.getAttribute("aria-hidden") !== "true"
    );
  }
  getInitialNavigationIndex(items) {
    return items.length > 0 ? 0 : -1;
  }
  setCurrentItemByIndex(index, items = this.getNavigableItems()) {
    const itemCount = items.length;
    if (itemCount === 0 || index < 0 || index >= itemCount) {
      this.currentIndex = -1;
      return null;
    }
    items.forEach((item, itemIndex) => {
      if (itemIndex === index) {
        item.setAttribute("aria-selected", "true");
        item.setAttribute("tabindex", "0");
        if (this.focus_selected) {
          this.focusElement(item);
        }
        this.scrollItemIntoView(item);
      } else {
        item.setAttribute("tabindex", "-1");
        item.removeAttribute("aria-selected");
      }
    });
    this.currentIndex = index;
    return items[index];
  }
  isPrintableKeyEvent(event) {
    return event.key.length === 1 && !event.altKey && !event.ctrlKey && !event.metaKey;
  }
  focusElement(element) {
    if (!element) {
      return;
    }
    if (typeof element.focus === "function") {
      try {
        element.focus({ preventScroll: true });
      } catch {
        element.focus();
      }
    }
  }
  resolveStrategy() {
    if (this.strategy === "absolute" || this.strategy === "fixed") {
      return this.strategy;
    }
    return this.hasNestedClippingAncestor() ? "fixed" : this.defaultStrategy;
  }
  hasNestedClippingAncestor() {
    if (!this.trigger) {
      return false;
    }
    return getOverflowAncestors(this.trigger).some(
      (ancestor) => this.isNestedClippingAncestor(ancestor)
    );
  }
  isNestedClippingAncestor(ancestor) {
    if (!(ancestor instanceof HTMLElement)) {
      return false;
    }
    const doc2 = ancestor.ownerDocument;
    if (!doc2 || ancestor === doc2.body || ancestor === doc2.documentElement || ancestor === this.el || ancestor === this.trigger || ancestor === this.popup) {
      return false;
    }
    const style = window.getComputedStyle(ancestor);
    return [style.overflow, style.overflowX, style.overflowY].some(
      (value) => ["auto", "scroll", "hidden", "clip", "overlay"].includes(value)
    );
  }
  scrollItemIntoView(item) {
    if (!item || !this.popup) {
      return;
    }
    const popupRect = this.popup.getBoundingClientRect();
    const itemRect = item.getBoundingClientRect();
    if (itemRect.top < popupRect.top) {
      this.popup.scrollTop -= popupRect.top - itemRect.top;
    } else if (itemRect.bottom > popupRect.bottom) {
      this.popup.scrollTop += itemRect.bottom - popupRect.bottom;
    }
  }
};

// js/date_picker.js
import { ViewHook as ViewHook2 } from "phoenix_live_view";
var DatePicker = class extends ViewHook2 {
  expanded = false;
  name = "date-picker";
  placement = "bottom-start";
  defaultPlacement = "bottom-start";
  activePlacement = "bottom-start";
  strategy = "absolute";
  // floating-ui strategy
  defaultStrategy = "absolute";
  currentStrategy = "absolute";
  event_trigger = "click";
  // "click" | "hover" | "focus"
  currentIndex = -1;
  expand_popover = false;
  // expand popover to match width of trigger
  focus_selected = true;
  pendingCalendarFocusDate = null;
  #outside_listener;
  #clear_floating;
  #triggerClickHandler;
  #triggerMouseEnterHandler;
  #triggerMouseLeaveHandler;
  #triggerFocusHandler;
  #triggerBlurHandler;
  #containerKeyDownHandler;
  #triggerKeyDownHandler;
  #externalCloseHandler;
  #inputSyncHandler;
  #selectChangeHandler;
  mounted() {
    this.defaultPlacement = this.el.dataset.placement || this.placement;
    this.activePlacement = this.defaultPlacement;
    this.placement = this.defaultPlacement;
    this.strategy = this.el.dataset.strategy || this.strategy;
    this.currentStrategy = this.resolveStrategy();
    this.event_trigger = this.el.dataset.trigger || this.event_trigger;
    this.cacheElements();
    this.refreshExpanded();
    this.#triggerClickHandler = this.handleTriggerClick.bind(this);
    this.#triggerMouseEnterHandler = this.handleTriggerMouseEnter.bind(this);
    this.#triggerMouseLeaveHandler = this.handleTriggerMouseLeave.bind(this);
    this.#triggerFocusHandler = this.handleTriggerFocus.bind(this);
    this.#triggerBlurHandler = this.handleTriggerBlur.bind(this);
    this.#containerKeyDownHandler = this.handleContainerKeyDown.bind(this);
    this.#triggerKeyDownHandler = this.handleTriggerKeyDown.bind(this);
    this.#externalCloseHandler = this.handleExternalClose.bind(this);
    this.#inputSyncHandler = this.handleInputSync.bind(this);
    this.#selectChangeHandler = this.handleSelectChange.bind(this);
    this.bindEventListeners();
    this.el.addEventListener("pui:popover-close", this.#externalCloseHandler);
    this.el.addEventListener("pui:date-picker-sync", this.#inputSyncHandler);
    this.el.addEventListener("change", this.#selectChangeHandler);
    this.ignoreHookManagedAttributes();
    this.#outside_listener = (event) => {
      const target = event.target;
      const clickedOnTrigger = this.trigger?.contains(target);
      const clickedOnPopup = this.popup?.contains(target);
      if (!clickedOnTrigger && !clickedOnPopup && this.expanded) {
        this.closePopover();
      }
    };
    this.initFloatingUI();
  }
  listenOutside() {
    document.addEventListener("click", this.#outside_listener);
  }
  removeOutsideListener() {
    document.removeEventListener("click", this.#outside_listener);
  }
  updated() {
    const previousTrigger = this.trigger;
    this.cacheElements();
    this.ignoreHookManagedAttributes();
    this.rebindEventListeners(previousTrigger);
    this.restoreExpanded();
    this.initFloatingUI();
    this.refreshFloatingUI();
    this.restorePendingCalendarFocus();
  }
  destroyed() {
    this.unbindEventListeners(this.trigger);
    document.removeEventListener("click", this.#outside_listener);
    this.el.removeEventListener("pui:popover-close", this.#externalCloseHandler);
    this.el.removeEventListener("pui:date-picker-sync", this.#inputSyncHandler);
    this.el.removeEventListener("change", this.#selectChangeHandler);
    if (this.#clear_floating) {
      this.#clear_floating();
    }
  }
  handleTriggerKeyDown(event) {
    if (!this.expanded && (event.key === "ArrowDown" || event.key === "ArrowUp")) {
      event.preventDefault();
      this.openPopover({ placement: this.getPlacementForKey(event.key) });
      return;
    }
    if (!this.expanded && this.isPrintableKeyEvent(event)) {
      const handled = this.handleTriggerTypeahead(event);
      if (handled) {
        event.preventDefault();
      }
    }
  }
  handleTriggerClick() {
    if (this.expanded) {
      this.closePopover();
    } else {
      this.openPopover({ placement: this.getOpenPlacement() });
    }
    this.refreshExpanded();
  }
  handleTriggerMouseEnter() {
    this.openPopover();
    this.refreshExpanded();
  }
  handleTriggerMouseLeave() {
    this.closePopover();
    this.refreshExpanded();
  }
  handleTriggerFocus() {
    this.openPopover();
    this.refreshExpanded();
  }
  handleTriggerBlur() {
    this.closePopover();
    this.refreshExpanded();
  }
  handleContainerKeyDown(event) {
    if (!this.expanded) return;
    if (["SELECT", "INPUT", "TEXTAREA"].includes(event.target?.tagName)) {
      return;
    }
    switch (event.key) {
      case "Escape":
        event.preventDefault();
        event.stopPropagation();
        this.closePopover();
        this.trigger?.focus();
        break;
      case "ArrowDown":
      case "ArrowUp":
      case "ArrowLeft":
      case "ArrowRight":
      case "Home":
      case "End":
        this.handleArrowNavigation(event);
        break;
      case "Enter":
        this.handleKeyEnter(event);
        break;
      case "Tab":
        this.closePopover();
        break;
      default:
        if (this.isPrintableKeyEvent(event)) {
          const handled = this.handlePrintableKey(event);
          if (handled) {
            event.preventDefault();
          }
        }
    }
  }
  handleKeyEnter(event) {
  }
  handleExternalClose() {
    if (!this.expanded) return;
    this.closePopover();
    this.refreshExpanded();
  }
  handleInputSync(event) {
    const inputId = event.detail?.input;
    const input = inputId ? document.getElementById(inputId) : null;
    if (!input) {
      return;
    }
    input.dispatchEvent(new Event("input", { bubbles: true }));
    input.dispatchEvent(new Event("change", { bubbles: true }));
  }
  handleSelectChange(event) {
    const target = event.target;
    if (!(target instanceof HTMLSelectElement)) {
      return;
    }
    const offset3 = target.dataset.offset;
    if (target.dataset.pui === "calendar-month-select") {
      event.stopPropagation();
      this.pushEventTo(this.el, "select_month", {
        month: target.value,
        offset: offset3
      });
      return;
    }
    if (target.dataset.pui === "calendar-year-select") {
      event.stopPropagation();
      this.pushEventTo(this.el, "select_year", {
        year: target.value,
        offset: offset3
      });
    }
  }
  handleTriggerTypeahead(_event) {
    return false;
  }
  handlePrintableKey(_event) {
    return false;
  }
  handleArrowNavigation(event) {
    if (!this.expanded) return;
    if (this.popup?.dataset.gridNavigation === "calendar" && ["ArrowLeft", "ArrowRight", "ArrowUp", "ArrowDown"].includes(event.key)) {
      event.preventDefault();
      this.handleCalendarArrowNavigation(event.key);
      return;
    }
    const visibleItems = this.getNavigableItems();
    const itemCount = visibleItems.length;
    if (itemCount === 0) return;
    event.preventDefault();
    let newIndex = this.currentIndex;
    switch (event.key) {
      case "ArrowDown":
        newIndex = (this.currentIndex + 1) % itemCount;
        break;
      case "ArrowUp":
        newIndex = (this.currentIndex - 1 + itemCount) % itemCount;
        break;
      case "Home":
        newIndex = 0;
        break;
      case "End":
        newIndex = itemCount - 1;
        break;
    }
    this.setCurrentItemByIndex(newIndex, visibleItems);
  }
  handleCalendarArrowNavigation(key) {
    const items = this.getNavigableItems();
    const currentIndex = this.currentIndex === -1 ? this.getInitialNavigationIndex(items) : this.currentIndex;
    const currentItem = items[currentIndex];
    const currentDate = currentItem?.dataset?.date;
    if (!currentDate) {
      return;
    }
    const dayOffset = key === "ArrowLeft" ? -1 : key === "ArrowRight" ? 1 : key === "ArrowUp" ? -7 : 7;
    const targetDate = this.addDays(currentDate, dayOffset);
    const targetIndex = this.findCalendarTargetIndex(
      items,
      currentIndex,
      targetDate,
      key
    );
    if (targetIndex !== -1) {
      this.setCurrentItemByIndex(targetIndex, items);
      return;
    }
    const direction = dayOffset < 0 ? "prev" : "next";
    const navButton = this.popup?.querySelector(`[data-pui="calendar-${direction}"]`);
    if (!navButton || navButton.disabled) {
      return;
    }
    this.pendingCalendarFocusDate = targetDate;
    this.pushEventTo(this.el, "navigate", { direction });
  }
  initFloatingUI() {
    if (this.#clear_floating) {
      this.#clear_floating();
    }
    if (!this.trigger || !this.popup) {
      return;
    }
    if (!this.expanded) {
      return;
    }
    this.currentStrategy = this.resolveStrategy();
    this.#clear_floating = autoUpdate(
      this.trigger,
      this.popup,
      () => {
        this.refreshFloatingUI();
      },
      {
        animationFrame: this.currentStrategy === "fixed"
      }
    );
  }
  bindEventListeners() {
    this.el.addEventListener("keydown", this.#containerKeyDownHandler);
    this.trigger?.addEventListener("keydown", this.#triggerKeyDownHandler);
    if (this.event_trigger === "click") {
      this.trigger?.addEventListener("click", this.#triggerClickHandler);
      return;
    }
    if (this.event_trigger === "hover") {
      this.trigger?.addEventListener(
        "mouseenter",
        this.#triggerMouseEnterHandler
      );
      this.trigger?.addEventListener(
        "mouseleave",
        this.#triggerMouseLeaveHandler
      );
      return;
    }
    if (this.event_trigger === "focus") {
      this.trigger?.addEventListener("focus", this.#triggerFocusHandler);
      this.trigger?.addEventListener("blur", this.#triggerBlurHandler);
    }
  }
  unbindEventListeners(trigger) {
    this.el.removeEventListener("keydown", this.#containerKeyDownHandler);
    trigger?.removeEventListener("keydown", this.#triggerKeyDownHandler);
    trigger?.removeEventListener("click", this.#triggerClickHandler);
    trigger?.removeEventListener("mouseenter", this.#triggerMouseEnterHandler);
    trigger?.removeEventListener("mouseleave", this.#triggerMouseLeaveHandler);
    trigger?.removeEventListener("focus", this.#triggerFocusHandler);
    trigger?.removeEventListener("blur", this.#triggerBlurHandler);
  }
  rebindEventListeners(previousTrigger) {
    if (previousTrigger === this.trigger) {
      return;
    }
    this.unbindEventListeners(previousTrigger);
    this.bindEventListeners();
  }
  refreshFloatingUI() {
    if (!this.trigger || !this.popup || !this.expanded) {
      return Promise.resolve();
    }
    const expand_popover = this.expand_popover;
    const collisionPadding = 8;
    const nextStrategy = this.resolveStrategy();
    if (nextStrategy !== this.currentStrategy) {
      this.currentStrategy = nextStrategy;
      this.initFloatingUI();
    } else {
      this.currentStrategy = nextStrategy;
    }
    return computePosition2(this.trigger, this.popup, {
      placement: this.activePlacement,
      strategy: this.currentStrategy,
      middleware: [
        offset2(collisionPadding),
        flip2({ padding: collisionPadding }),
        shift2({ padding: collisionPadding }),
        size2({
          padding: collisionPadding,
          apply({ rects, elements }) {
            if (expand_popover) {
              elements.floating.style.width = `${Math.max(0, Math.floor(rects.reference.width))}px`;
            } else {
              elements.floating.style.removeProperty("width");
            }
          }
        }),
        hide2({ padding: collisionPadding })
      ]
    }).then(({ x, y, strategy, placement, middlewareData }) => {
      const referenceHidden = Boolean(middlewareData.hide?.referenceHidden);
      Object.assign(this.popup.style, {
        left: `${x}px`,
        top: `${y}px`,
        position: strategy
      });
      this.popup.dataset.side = placement.split("-")[0];
      this.popup.dataset.floatingStrategy = strategy;
      this.popup.dataset.referenceHidden = String(referenceHidden);
      if (referenceHidden && this.expanded) {
        this.closePopover({ restoreFocus: false });
      }
    });
  }
  closePopover(options = {}) {
    const { restoreFocus = true } = options;
    this.trigger?.setAttribute("aria-expanded", "false");
    this.popup?.setAttribute("aria-hidden", "true");
    this.expanded = false;
    this.currentIndex = -1;
    this.activePlacement = this.defaultPlacement;
    this.onPopupClosed(restoreFocus);
    this.popup?.setAttribute("data-reference-hidden", "false");
    this.removeOutsideListener();
    this.initFloatingUI();
  }
  onPopupOpened() {
  }
  onPopupClosed(restoreFocus = true) {
    if (this.popup?.contains(document.activeElement) || this.trigger?.contains(document.activeElement)) {
      if (restoreFocus) {
        this.focusElement(this.trigger);
      } else if (typeof document.activeElement?.blur === "function") {
        document.activeElement.blur();
      }
    }
  }
  openPopover(options = {}) {
    this.activePlacement = options.placement || this.getOpenPlacement();
    this.trigger?.setAttribute("aria-expanded", "true");
    this.popup?.setAttribute("aria-hidden", "false");
    this.popup?.setAttribute("data-reference-hidden", "false");
    this.focusElement(this.popup);
    this.expanded = true;
    this.currentIndex = this.getInitialNavigationIndex(
      this.getNavigableItems()
    );
    this.onPopupOpened();
    this.listenOutside();
    this.initFloatingUI();
    this.refreshFloatingUI();
    requestAnimationFrame(() => {
      if (!this.expanded) return;
      if (this.currentIndex !== -1) {
        this.setCurrentItemByIndex(this.currentIndex);
      } else {
        this.focusElement(this.popup);
      }
    });
  }
  log(msg, data) {
    console.log(`${this.name}: ${msg}`, data);
  }
  refreshExpanded() {
    this.expanded = this.trigger?.getAttribute("aria-expanded") == "true";
  }
  restoreExpanded() {
    if (this.expanded) {
      this.openPopover({ placement: this.activePlacement });
    } else {
      this.closePopover();
    }
  }
  cacheElements() {
    this.trigger = this.el.querySelector("[aria-haspopup],[role='combobox']");
    this.popup = this.el.querySelector("[role='menu'],[role='listbox']");
    this.items = this.popup?.querySelectorAll("[role='option'],[role='menuitem']") ?? [];
  }
  ignoreHookManagedAttributes() {
    if (this.trigger) {
      this.js().ignoreAttributes(this.trigger, ["aria-expanded"]);
    }
    if (this.popup) {
      this.js().ignoreAttributes(this.popup, ["aria-*", "data-*", "style"]);
    }
  }
  getOpenPlacement() {
    return this.defaultPlacement;
  }
  getPlacementForKey(_key) {
    return this.defaultPlacement;
  }
  getNavigableItems() {
    return Array.from(this.items).filter(
      (item) => item.style.display !== "none" && item.getAttribute("aria-disabled") !== "true" && item.getAttribute("aria-hidden") !== "true"
    );
  }
  getInitialNavigationIndex(items) {
    const focusDate = this.popup?.dataset.focusDate;
    if (focusDate) {
      const focusedIndex = items.findIndex((item) => item.dataset?.date === focusDate);
      if (focusedIndex !== -1) {
        return focusedIndex;
      }
    }
    return items.length > 0 ? 0 : -1;
  }
  setCurrentItemByIndex(index, items = this.getNavigableItems()) {
    const itemCount = items.length;
    if (itemCount === 0 || index < 0 || index >= itemCount) {
      this.currentIndex = -1;
      return null;
    }
    items.forEach((item, itemIndex) => {
      if (itemIndex === index) {
        item.setAttribute("aria-selected", "true");
        item.setAttribute("tabindex", "0");
        if (this.focus_selected) {
          this.focusElement(item);
        }
        this.scrollItemIntoView(item);
      } else {
        item.setAttribute("tabindex", "-1");
        item.removeAttribute("aria-selected");
      }
    });
    this.currentIndex = index;
    return items[index];
  }
  isPrintableKeyEvent(event) {
    return event.key.length === 1 && !event.altKey && !event.ctrlKey && !event.metaKey;
  }
  focusElement(element) {
    if (!element) {
      return;
    }
    if (typeof element.focus === "function") {
      try {
        element.focus({ preventScroll: true });
      } catch {
        element.focus();
      }
    }
  }
  restorePendingCalendarFocus() {
    if (!this.pendingCalendarFocusDate || !this.expanded) {
      return;
    }
    requestAnimationFrame(() => {
      if (!this.expanded) return;
      const items = this.getNavigableItems();
      const targetIndex = items.findIndex(
        (item) => item.dataset?.date === this.pendingCalendarFocusDate
      );
      if (targetIndex !== -1) {
        this.setCurrentItemByIndex(targetIndex, items);
      }
      this.pendingCalendarFocusDate = null;
    });
  }
  addDays(value, offset3) {
    const date = this.parseISODate(value);
    if (!date) {
      return value;
    }
    date.setUTCDate(date.getUTCDate() + offset3);
    return this.formatISODate(date);
  }
  parseISODate(value) {
    const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(value);
    if (!match) {
      return null;
    }
    const [, year, month, day] = match;
    const date = new Date(Date.UTC(Number(year), Number(month) - 1, Number(day)));
    return Number.isNaN(date.getTime()) ? null : date;
  }
  formatISODate(date) {
    const year = String(date.getUTCFullYear());
    const month = String(date.getUTCMonth() + 1).padStart(2, "0");
    const day = String(date.getUTCDate()).padStart(2, "0");
    return `${year}-${month}-${day}`;
  }
  findCalendarTargetIndex(items, currentIndex, targetDate, key) {
    const candidates = items.map((item, index) => ({ item, index })).filter(({ item }) => item.dataset?.date === targetDate);
    if (candidates.length === 0) {
      return -1;
    }
    const inMonthCandidate = candidates.find(
      ({ item }) => item.dataset?.outsideMonth !== "true"
    );
    if (inMonthCandidate) {
      return inMonthCandidate.index;
    }
    if (key === "ArrowRight" || key === "ArrowDown") {
      return candidates.find(({ index }) => index > currentIndex)?.index ?? candidates[candidates.length - 1].index;
    }
    if (key === "ArrowLeft" || key === "ArrowUp") {
      return [...candidates].reverse().find(({ index }) => index < currentIndex)?.index ?? candidates[0].index;
    }
    return candidates[0].index;
  }
  resolveStrategy() {
    if (this.strategy === "absolute" || this.strategy === "fixed") {
      return this.strategy;
    }
    return this.hasNestedClippingAncestor() ? "fixed" : this.defaultStrategy;
  }
  hasNestedClippingAncestor() {
    if (!this.trigger) {
      return false;
    }
    return getOverflowAncestors(this.trigger).some(
      (ancestor) => this.isNestedClippingAncestor(ancestor)
    );
  }
  isNestedClippingAncestor(ancestor) {
    if (!(ancestor instanceof HTMLElement)) {
      return false;
    }
    const doc2 = ancestor.ownerDocument;
    if (!doc2 || ancestor === doc2.body || ancestor === doc2.documentElement || ancestor === this.el || ancestor === this.trigger || ancestor === this.popup) {
      return false;
    }
    const style = window.getComputedStyle(ancestor);
    return [style.overflow, style.overflowX, style.overflowY].some(
      (value) => ["auto", "scroll", "hidden", "clip", "overlay"].includes(value)
    );
  }
  scrollItemIntoView(item) {
    if (!item || !this.popup) {
      return;
    }
    const popupRect = this.popup.getBoundingClientRect();
    const itemRect = item.getBoundingClientRect();
    if (itemRect.top < popupRect.top) {
      this.popup.scrollTop -= popupRect.top - itemRect.top;
    } else if (itemRect.bottom > popupRect.bottom) {
      this.popup.scrollTop += itemRect.bottom - popupRect.bottom;
    }
  }
};

// js/select.js
import { ViewHook as ViewHook3 } from "phoenix_live_view";
var Select = class extends ViewHook3 {
  expanded = false;
  placement = "bottom-start";
  activePlacement = "bottom-start";
  strategy = "auto";
  defaultStrategy = "absolute";
  currentStrategy = "absolute";
  currentIndex = -1;
  expandPopover = true;
  focusSelected = false;
  popupMinWidth = 208;
  #clearFloating;
  #outsideListener;
  #triggerClickHandler;
  #triggerKeyDownHandler;
  #containerKeyDownHandler;
  #popupClickHandler;
  #searchInputHandler;
  #searchKeyDownHandler;
  #typeaheadBuffer = "";
  #typeaheadTimeout;
  mounted() {
    this.placement = this.el.dataset.placement || this.placement;
    this.activePlacement = this.placement;
    this.strategy = this.el.dataset.strategy || this.strategy;
    this.currentStrategy = this.resolveStrategy();
    this.cacheElements();
    this.refreshExpanded();
    this.#triggerClickHandler = this.handleTriggerClick.bind(this);
    this.#triggerKeyDownHandler = this.handleTriggerKeyDown.bind(this);
    this.#containerKeyDownHandler = this.handleContainerKeyDown.bind(this);
    this.#popupClickHandler = this.handlePopupClick.bind(this);
    this.#searchInputHandler = this.handleSearchInput.bind(this);
    this.#searchKeyDownHandler = this.handleSearchKeyDown.bind(this);
    this.bindEventListeners();
    this.#outsideListener = (event) => {
      const target = event.target;
      const clickedOnTrigger = this.trigger?.contains(target);
      const clickedOnPopup = this.popup?.contains(target);
      if (!clickedOnTrigger && !clickedOnPopup && this.expanded) {
        this.closePopover();
      }
    };
    this.initFloatingUI();
    this.ensureOptionMetadata();
    this.selectDefaultValue();
  }
  updated() {
    const previousTrigger = this.trigger;
    const previousPopup = this.popup;
    const previousSearch = this.search;
    this.cacheElements();
    this.rebindEventListeners(previousTrigger, previousPopup, previousSearch);
    this.ensureOptionMetadata();
    this.syncValueFromDataset();
    this.restoreExpanded();
    this.initFloatingUI();
    this.refreshFloatingUI();
  }
  destroyed() {
    this.unbindEventListeners(this.trigger, this.popup, this.search);
    document.removeEventListener("click", this.#outsideListener);
    if (this.#clearFloating) {
      this.#clearFloating();
    }
    this.resetTypeahead();
  }
  cacheElements() {
    this.trigger = this.el.querySelector("[aria-haspopup],[role='combobox']");
    this.popup = this.el.querySelector("[role='menu'],[role='listbox']");
    this.viewport = this.el.querySelector("[data-pui='menu-viewport']") || this.popup;
    this.items = this.popup?.querySelectorAll("[role='option'],[role='menuitem']") ?? [];
    this.search = this.el.querySelector(
      "input[type='text'][role='searchbox'], input[type='text'][role='combobox']"
    );
    this.hiddenInput = this.el.querySelector("input[data-pui='select-value']");
    this.label = this.el.querySelector("[data-pui='selected-label']");
    this.popupMinWidth = Number.parseFloat(this.popup?.dataset.popupMinWidth || `${this.popupMinWidth}`) || this.popupMinWidth;
  }
  bindEventListeners() {
    this.el.addEventListener("keydown", this.#containerKeyDownHandler);
    this.trigger?.addEventListener("click", this.#triggerClickHandler);
    this.trigger?.addEventListener("keydown", this.#triggerKeyDownHandler);
    this.popup?.addEventListener("click", this.#popupClickHandler);
    this.search?.addEventListener("keydown", this.#searchKeyDownHandler);
  }
  unbindEventListeners(trigger, popup, search) {
    this.el.removeEventListener("keydown", this.#containerKeyDownHandler);
    trigger?.removeEventListener("click", this.#triggerClickHandler);
    trigger?.removeEventListener("keydown", this.#triggerKeyDownHandler);
    popup?.removeEventListener("click", this.#popupClickHandler);
    search?.removeEventListener("keydown", this.#searchKeyDownHandler);
    search?.removeEventListener("input", this.#searchInputHandler);
  }
  rebindEventListeners(previousTrigger, previousPopup, previousSearch) {
    if (previousTrigger === this.trigger && previousPopup === this.popup && previousSearch === this.search) {
      return;
    }
    this.unbindEventListeners(previousTrigger, previousPopup, previousSearch);
    this.bindEventListeners();
    if (this.expanded) {
      this.search?.addEventListener("input", this.#searchInputHandler);
    }
  }
  refreshExpanded() {
    this.expanded = this.trigger?.getAttribute("aria-expanded") === "true";
  }
  restoreExpanded() {
    if (this.expanded) {
      this.openPopover({ placement: this.activePlacement });
    } else {
      this.closePopover();
    }
  }
  handleTriggerClick() {
    if (this.expanded) {
      this.closePopover();
    } else {
      this.openPopover({ placement: this.placement });
    }
    this.refreshExpanded();
  }
  handleTriggerKeyDown(event) {
    if (!this.expanded && (event.key === "ArrowDown" || event.key === "ArrowUp")) {
      event.preventDefault();
      event.stopPropagation();
      this.openPopover({ placement: this.getPlacementForKey(event.key) });
      return;
    }
    if (!this.expanded && this.isPrintableKeyEvent(event)) {
      const handled = this.handleTriggerTypeahead(event);
      if (handled) {
        event.preventDefault();
      }
    }
  }
  handleContainerKeyDown(event) {
    if (!this.expanded) {
      return;
    }
    switch (event.key) {
      case "Escape":
        event.preventDefault();
        event.stopPropagation();
        this.closePopover();
        this.focusElement(this.trigger);
        break;
      case "ArrowDown":
      case "ArrowUp":
      case "Home":
      case "End":
        this.handleArrowNavigation(event);
        break;
      case "Enter":
        this.handleKeyEnter(event);
        break;
      case "Tab":
        this.closePopover();
        break;
      default:
        if (this.isPrintableKeyEvent(event)) {
          const handled = this.handlePrintableKey(event);
          if (handled) {
            event.preventDefault();
          }
        }
    }
  }
  handleArrowNavigation(event) {
    const visibleItems = this.getNavigableItems();
    const itemCount = visibleItems.length;
    if (itemCount === 0) {
      return;
    }
    event.preventDefault();
    if (this.currentIndex < 0) {
      const initialIndex = this.getInitialNavigationIndex(visibleItems);
      this.setCurrentItemByIndex(initialIndex, visibleItems);
      return;
    }
    let newIndex = this.currentIndex;
    switch (event.key) {
      case "ArrowDown":
        newIndex = (this.currentIndex + 1) % itemCount;
        break;
      case "ArrowUp":
        newIndex = (this.currentIndex - 1 + itemCount) % itemCount;
        break;
      case "Home":
        newIndex = 0;
        break;
      case "End":
        newIndex = itemCount - 1;
        break;
    }
    this.setCurrentItemByIndex(newIndex, visibleItems);
  }
  handleKeyEnter(event) {
    if (this.currentIndex < 0) {
      return;
    }
    event.preventDefault();
    const visibleItems = this.getNavigableItems();
    const currentItem = visibleItems[this.currentIndex];
    if (currentItem) {
      this.selectItem(currentItem);
    }
  }
  handlePopupClick(event) {
    const item = event.target?.closest("[role='option'],[role='menuitem']");
    if (item && this.popup?.contains(item)) {
      this.selectItem(item);
    }
  }
  handleSearchInput(event) {
    event.stopPropagation();
    const query2 = event.target.value.toLowerCase();
    this.currentIndex = -1;
    this.items.forEach((item) => {
      const itemText = (item.dataset.label || item.textContent).trim().toLowerCase();
      const matches = itemText.includes(query2);
      item.setAttribute("aria-hidden", String(!matches));
    });
    const visibleItems = this.getNavigableItems();
    const nextIndex = this.getInitialNavigationIndex(visibleItems);
    this.setCurrentItemByIndex(nextIndex, visibleItems);
  }
  handleSearchKeyDown(event) {
    switch (event.key) {
      case "ArrowDown":
      case "ArrowUp":
      case "Home":
      case "End":
      case "Enter":
      case "Escape":
        this.handleContainerKeyDown(event);
        event.stopPropagation();
        break;
    }
  }
  handleTriggerTypeahead(event) {
    const item = this.findTypeaheadMatch(event.key);
    if (!item) {
      return false;
    }
    this.selectItem(item, { close: false });
    return true;
  }
  handlePrintableKey(event) {
    if (event.target === this.search) {
      return false;
    }
    const visibleItems = this.getNavigableItems();
    const item = this.findTypeaheadMatch(event.key, visibleItems);
    if (!item) {
      return false;
    }
    const itemIndex = visibleItems.findIndex((visibleItem) => visibleItem === item);
    this.setCurrentItemByIndex(itemIndex, visibleItems);
    this.selectItem(item, { close: false, focusTrigger: false });
    return true;
  }
  getPlacementForKey(key) {
    if (key === "ArrowUp") {
      return "top-start";
    }
    return this.placement;
  }
  getNavigableItems() {
    return Array.from(this.items).filter(
      (item) => item.style.display !== "none" && item.getAttribute("aria-disabled") !== "true" && item.getAttribute("aria-hidden") !== "true"
    );
  }
  getInitialNavigationIndex(items) {
    const selectedValue = this.hiddenInput?.value;
    const selectedIndex = items.findIndex(
      (item) => item.dataset.value === selectedValue
    );
    return selectedIndex >= 0 ? selectedIndex : items.length > 0 ? 0 : -1;
  }
  setCurrentItemByIndex(index, items = this.getNavigableItems(), options = {}) {
    const { scrollAlignment = "nearest" } = options;
    const itemCount = items.length;
    if (itemCount === 0 || index < 0 || index >= itemCount) {
      this.currentIndex = -1;
      this.clearActiveItems();
      this.setActiveDescendant(null);
      return null;
    }
    items.forEach((item, itemIndex) => {
      item.setAttribute("tabindex", itemIndex === index ? "0" : "-1");
      item.dataset.active = String(itemIndex === index);
      if (itemIndex === index) {
        if (this.focusSelected) {
          this.focusElement(item);
        }
        this.scrollItemIntoView(item, { alignment: scrollAlignment });
      }
    });
    this.currentIndex = index;
    this.setActiveDescendant(items[index]);
    return items[index];
  }
  syncValueFromDataset() {
    const serverValue = this.el.dataset.value;
    if (!this.hiddenInput) {
      return;
    }
    if (serverValue !== void 0 && this.hiddenInput.value !== serverValue) {
      const serverItem = Array.from(this.items).find(
        (item) => item.dataset.value === serverValue
      );
      if (serverItem) {
        this.selectItem(serverItem, { close: false, focusTrigger: false });
      } else {
        this.hiddenInput.value = serverValue;
        this.updatePlaceholder();
      }
    }
  }
  ensureOptionMetadata() {
    this.items.forEach((item, index) => {
      if (!item.id) {
        item.id = `${this.el.id || "pui-select"}-option-${index}`;
      }
      if (!item.dataset.label) {
        item.dataset.label = item.textContent.trim();
      }
      item.setAttribute("tabindex", "-1");
    });
  }
  selectDefaultValue() {
    const defaultValue = this.el.dataset.value;
    if (!defaultValue) {
      return;
    }
    const defaultItem = Array.from(this.items).find(
      (item) => item.dataset.value === defaultValue
    );
    if (defaultItem) {
      this.selectItem(defaultItem, { close: false, focusTrigger: false });
    }
  }
  selectItem(itemEl, options = {}) {
    const { close = true, focusTrigger = true } = options;
    if (this.hiddenInput) {
      const newValue = itemEl.dataset.value;
      if (newValue && this.hiddenInput.value !== newValue) {
        this.hiddenInput.value = newValue;
        this.hiddenInput.dispatchEvent(new Event("change", { bubbles: true }));
      }
    }
    this.setSelectedItem(itemEl);
    this.updatePlaceholder();
    if (close) {
      this.closePopover();
    } else if (focusTrigger) {
      this.focusElement(this.trigger);
    }
  }
  setSelectedItem(selectedItem) {
    this.items.forEach((item) => {
      const isSelected = item === selectedItem;
      item.setAttribute("aria-selected", String(isSelected));
      item.setAttribute("tabindex", isSelected ? "0" : "-1");
    });
    const visibleItems = this.getNavigableItems();
    this.currentIndex = visibleItems.findIndex((item) => item === selectedItem);
    this.setActiveDescendant(selectedItem);
  }
  clearActiveItems() {
    this.items.forEach((item) => {
      delete item.dataset.active;
    });
  }
  updatePlaceholder() {
    const selectedItem = Array.from(this.items).find(
      (item) => item.dataset.value === this.hiddenInput?.value
    );
    if (this.label) {
      this.label.textContent = selectedItem ? selectedItem.textContent : "";
    }
  }
  setActiveDescendant(item) {
    const activeId = item?.id;
    if (activeId) {
      this.trigger?.setAttribute("aria-activedescendant", activeId);
      this.search?.setAttribute("aria-activedescendant", activeId);
      return;
    }
    this.trigger?.removeAttribute("aria-activedescendant");
    this.search?.removeAttribute("aria-activedescendant");
  }
  clearSearch() {
    if (this.search) {
      this.search.value = "";
    }
    this.items.forEach((item) => {
      item.removeAttribute("aria-hidden");
    });
    this.resetTypeahead();
  }
  openPopover(options = {}) {
    this.activePlacement = options.placement || this.placement;
    this.trigger?.setAttribute("aria-expanded", "true");
    this.popup?.setAttribute("aria-hidden", "false");
    this.popup?.setAttribute("data-reference-hidden", "false");
    this.expanded = true;
    const visibleItems = this.getNavigableItems();
    this.currentIndex = this.getInitialNavigationIndex(visibleItems);
    this.setCurrentItemByIndex(this.currentIndex, visibleItems, {
      scrollAlignment: "none"
    });
    if (this.search) {
      this.search.setAttribute("aria-expanded", "true");
      this.search.addEventListener("input", this.#searchInputHandler);
      this.focusElement(this.search);
    } else {
      this.focusElement(this.popup);
    }
    this.initFloatingUI();
    this.listenOutside();
    this.refreshFloatingUI().then(() => {
      const currentItems = this.getNavigableItems();
      this.currentIndex = this.getInitialNavigationIndex(currentItems);
      this.setCurrentItemByIndex(this.currentIndex, currentItems, {
        scrollAlignment: "center-if-needed"
      });
    });
  }
  closePopover(options = {}) {
    const { restoreFocus = true } = options;
    this.trigger?.setAttribute("aria-expanded", "false");
    this.popup?.setAttribute("aria-hidden", "true");
    this.search?.setAttribute("aria-expanded", "false");
    this.search?.removeEventListener("input", this.#searchInputHandler);
    this.expanded = false;
    this.currentIndex = -1;
    this.activePlacement = this.placement;
    this.clearActiveItems();
    if (this.search) {
      this.clearSearch();
    }
    this.setActiveDescendant(
      Array.from(this.items).find(
        (item) => item.dataset.value === this.hiddenInput?.value
      )
    );
    if (this.popup?.contains(document.activeElement) || this.trigger?.contains(document.activeElement)) {
      if (restoreFocus) {
        this.focusElement(this.trigger);
      } else if (typeof document.activeElement?.blur === "function") {
        document.activeElement.blur();
      }
    }
    this.popup?.setAttribute("data-reference-hidden", "false");
    this.popup?.style.removeProperty("--pui-select-content-available-height");
    this.removeOutsideListener();
    this.initFloatingUI();
  }
  initFloatingUI() {
    if (this.#clearFloating) {
      this.#clearFloating();
    }
    if (!this.trigger || !this.popup) {
      return;
    }
    if (!this.expanded) {
      return;
    }
    this.currentStrategy = this.resolveStrategy();
    this.#clearFloating = autoUpdate(this.trigger, this.popup, () => {
      this.refreshFloatingUI();
    }, {
      animationFrame: this.currentStrategy === "fixed"
    });
  }
  refreshFloatingUI() {
    if (!this.trigger || !this.popup || !this.expanded) {
      return Promise.resolve();
    }
    const expandPopover = this.expandPopover;
    const defaultPopupMinWidth = this.popupMinWidth;
    const collisionPadding = 8;
    const nextStrategy = this.resolveStrategy();
    if (nextStrategy !== this.currentStrategy) {
      this.currentStrategy = nextStrategy;
      this.initFloatingUI();
    } else {
      this.currentStrategy = nextStrategy;
    }
    return computePosition2(this.trigger, this.popup, {
      placement: this.activePlacement,
      strategy: this.currentStrategy,
      middleware: [
        offset2(collisionPadding),
        flip2({ padding: collisionPadding }),
        shift2({ padding: collisionPadding }),
        size2({
          padding: collisionPadding,
          apply({ availableHeight, rects, elements }) {
            const nextAvailableHeight = `${Math.max(0, Math.floor(availableHeight))}px`;
            const nextTriggerWidth = Math.max(0, Math.floor(rects.reference.width));
            const popupMinWidth = Number.parseFloat(
              elements.floating.dataset.popupMinWidth || `${defaultPopupMinWidth}`
            ) || defaultPopupMinWidth;
            const nextPopupWidth = `${Math.max(
              popupMinWidth,
              nextTriggerWidth
            )}px`;
            elements.floating.style.setProperty(
              "--pui-select-content-available-height",
              nextAvailableHeight
            );
            elements.floating.style.setProperty(
              "--pui-select-trigger-width",
              `${nextTriggerWidth}px`
            );
            elements.floating.style.minWidth = nextPopupWidth;
            if (expandPopover) {
              elements.floating.style.width = nextPopupWidth;
            } else {
              elements.floating.style.removeProperty("width");
            }
          }
        }),
        hide2({ padding: collisionPadding })
      ]
    }).then(({ x, y, strategy, placement, middlewareData }) => {
      const referenceHidden = Boolean(middlewareData.hide?.referenceHidden);
      Object.assign(this.popup.style, {
        left: `${x}px`,
        top: `${y}px`,
        position: strategy
      });
      this.popup.dataset.side = placement.split("-")[0];
      this.popup.dataset.floatingStrategy = strategy;
      this.popup.dataset.referenceHidden = String(referenceHidden);
      if (referenceHidden && this.expanded) {
        this.closePopover({ restoreFocus: false });
      }
    });
  }
  listenOutside() {
    document.addEventListener("click", this.#outsideListener);
  }
  removeOutsideListener() {
    document.removeEventListener("click", this.#outsideListener);
  }
  findTypeaheadMatch(key, items = Array.from(this.items)) {
    const normalizedKey = key.toLowerCase();
    const navigableItems = items.filter(
      (item) => item.getAttribute("aria-hidden") !== "true" && item.getAttribute("aria-disabled") !== "true"
    );
    if (navigableItems.length === 0) {
      return null;
    }
    this.#typeaheadBuffer = `${this.#typeaheadBuffer}${normalizedKey}`;
    this.resetTypeaheadTimer();
    const currentValue = this.hiddenInput?.value;
    const startIndex = navigableItems.findIndex(
      (item) => item.dataset.value === currentValue
    );
    const orderedItems = [
      ...navigableItems.slice(startIndex + 1),
      ...navigableItems.slice(0, startIndex + 1)
    ];
    return orderedItems.find(
      (item) => item.dataset.label.toLowerCase().startsWith(this.#typeaheadBuffer)
    ) || orderedItems.find(
      (item) => item.dataset.label.toLowerCase().startsWith(normalizedKey)
    ) || null;
  }
  resetTypeaheadTimer() {
    window.clearTimeout(this.#typeaheadTimeout);
    this.#typeaheadTimeout = window.setTimeout(() => {
      this.resetTypeahead();
    }, 700);
  }
  resetTypeahead() {
    this.#typeaheadBuffer = "";
    window.clearTimeout(this.#typeaheadTimeout);
  }
  isPrintableKeyEvent(event) {
    return event.key.length === 1 && !event.altKey && !event.ctrlKey && !event.metaKey;
  }
  focusElement(element) {
    if (!element || typeof element.focus !== "function") {
      return;
    }
    try {
      element.focus({ preventScroll: true });
    } catch {
      element.focus();
    }
  }
  resolveStrategy() {
    if (this.strategy === "absolute" || this.strategy === "fixed") {
      return this.strategy;
    }
    return this.hasNestedClippingAncestor() ? "fixed" : this.defaultStrategy;
  }
  hasNestedClippingAncestor() {
    if (!this.trigger) {
      return false;
    }
    return getOverflowAncestors(this.trigger).some(
      (ancestor) => this.isNestedClippingAncestor(ancestor)
    );
  }
  isNestedClippingAncestor(ancestor) {
    if (!(ancestor instanceof HTMLElement)) {
      return false;
    }
    const doc2 = ancestor.ownerDocument;
    if (!doc2 || ancestor === doc2.body || ancestor === doc2.documentElement || ancestor === this.el || ancestor === this.trigger || ancestor === this.popup) {
      return false;
    }
    const style = window.getComputedStyle(ancestor);
    return [style.overflow, style.overflowX, style.overflowY].some(
      (value) => ["auto", "scroll", "hidden", "clip", "overlay"].includes(value)
    );
  }
  scrollItemIntoView(item, options = {}) {
    const scrollContainer = this.viewport || this.popup;
    if (!item || !scrollContainer) {
      return;
    }
    const { alignment = "nearest" } = options;
    const containerRect = scrollContainer.getBoundingClientRect();
    const itemRect = item.getBoundingClientRect();
    const itemIsAbove = itemRect.top < containerRect.top;
    const itemIsBelow = itemRect.bottom > containerRect.bottom;
    if (alignment === "none") {
      return;
    }
    if (alignment === "center-if-needed") {
      if (!itemIsAbove && !itemIsBelow) {
        return;
      }
      const maxScrollTop = Math.max(
        0,
        scrollContainer.scrollHeight - scrollContainer.clientHeight
      );
      const centeredScrollTop = scrollContainer.scrollTop + (itemRect.top - containerRect.top) - scrollContainer.clientHeight / 2 + itemRect.height / 2;
      scrollContainer.scrollTop = Math.min(
        maxScrollTop,
        Math.max(0, centeredScrollTop)
      );
      return;
    }
    if (itemIsAbove) {
      scrollContainer.scrollTop -= containerRect.top - itemRect.top;
    } else if (itemIsBelow) {
      scrollContainer.scrollTop += itemRect.bottom - containerRect.bottom;
    }
  }
};

// js/loading.js
import { ViewHook as ViewHook4 } from "phoenix_live_view";
State = {
  IDLE: 0,
  STARTING: 1
};
var LoadingBar = class extends ViewHook4 {
  progress = 0;
  delay = 300;
  delayTimer = null;
  raf = null;
  state = State.IDLE;
  #boundShow = null;
  #boundHide = null;
  mounted() {
    this.progressEl = this.el.querySelector("#loadingbar-progress");
    this.delay = parseInt(this.el.dataset.delay || "0") || this.delay;
    this.#boundShow = this._show.bind(this);
    this.#boundHide = this._hide.bind(this);
    this.state = State.IDLE;
    window.addEventListener("phx:page-loading-start", this.#boundShow);
    window.addEventListener("phx:page-loading-stop", this.#boundHide);
  }
  _show(info) {
    this._clear();
    this.delayTimer = setTimeout(() => {
      if (this.state === State.IDLE) {
        this.state = State.STARTING;
        this._start();
      }
    }, this.delay);
  }
  _start() {
    let lastTime = performance.now();
    const step = (now) => {
      const dt = now - lastTime;
      lastTime = now;
      if (this.progress < 50) {
        const delta = (100 - this.progress) * 0.01 * (dt / 16);
        this.progress = Math.min(this.progress + delta, 50);
      } else if (this.progress < 90) {
        const delta = (100 - this.progress) * 25e-4 * (dt / 16);
        this.progress = Math.min(this.progress + delta, 90);
      } else if (this.progress < 99) {
        const delta = (100 - this.progress) * 5e-4 * (dt / 16);
        this.progress = Math.min(this.progress + delta, 99);
      }
      this.progressEl.style.width = `${this.progress}%`;
      this.raf = requestAnimationFrame(step);
    };
    this.raf = requestAnimationFrame(step);
  }
  _reset() {
    this.progressEl.style.transition = "none";
    this.progressEl.style.width = "0%";
    this.progressEl.offsetHeight;
    this.progressEl.style.transition = "";
    this.progress = 0;
    this._clear();
    this.state = State.IDLE;
    cancelAnimationFrame(this.raf);
  }
  _hide(info) {
    this.state = State.IDLE;
    this._clear();
    if (this.progress > 0) {
      this.progress = 100;
      this.progressEl.style.width = "100%";
    }
    setTimeout(() => {
      this._reset();
    }, 500);
  }
  _clear() {
    if (this.delayTimer) {
      clearTimeout(this.delayTimer);
      this.delayTimer = null;
    }
  }
  destroyed() {
    window.removeEventListener("phx:page-loading-start", this.#boundShow);
    window.removeEventListener("phx:page-loading-stop", this.#boundHide);
  }
};

// js/tooltip.js
import { ViewHook as ViewHook5 } from "phoenix_live_view";
var Tooltip = class extends ViewHook5 {
  placement = "top";
  delay = 300;
  hovering = false;
  #clear_floating;
  #enterBind;
  #leaveBind;
  #focusInBind;
  #focusOutBind;
  leaveTimeout = null;
  mounted() {
    this.trigger = this.el.querySelector(':scope > :not([role="tooltip"])');
    this.tooltip = this.el.querySelector(':scope > [role="tooltip"]');
    this.arrow = this.el.querySelector(
      ':scope > [role="tooltip"] > [data-arrow]'
    );
    this.js().ignoreAttributes(this.tooltip, ["aria-*", "data-*", "style"]);
    this.trigger?.setAttribute("aria-describedby", this.tooltip?.id || "");
    this.placement = this.el.dataset.placement || this.placement;
    this.delay = this.el.dataset.delay || this.delay;
    this.#clear_floating = autoUpdate(this.trigger, this.tooltip, () => {
      this._calculatePosition();
    });
    this.#enterBind = this._onMouseEnter.bind(this);
    this.#leaveBind = this._onMouseLeave.bind(this);
    this.#focusInBind = this._onFocusIn.bind(this);
    this.#focusOutBind = this._onFocusOut.bind(this);
    this.el?.addEventListener("mouseenter", this.#enterBind);
    this.el?.addEventListener("mouseleave", this.#leaveBind);
    this.el?.addEventListener("focusin", this.#focusInBind);
    this.el?.addEventListener("focusout", this.#focusOutBind);
  }
  updated() {
    this.setHidden(this.hovering ? false : true);
    this._calculatePosition();
  }
  destroyed() {
    if (this.#clear_floating) {
      this.#clear_floating();
    }
    this.el?.removeEventListener("mouseenter", this.#enterBind);
    this.el?.removeEventListener("mouseleave", this.#leaveBind);
    this.el?.removeEventListener("focusin", this.#focusInBind);
    this.el?.removeEventListener("focusout", this.#focusOutBind);
  }
  setHidden(hidden) {
    requestAnimationFrame(() => {
      this.tooltip?.setAttribute("aria-hidden", hidden ? "true" : "false");
    });
  }
  _onMouseEnter(e) {
    this.hovering = true;
    if (this.leaveTimeout) clearTimeout(this.leaveTimeout);
    this.setHidden(false);
  }
  _onMouseLeave(e) {
    if (this.leaveTimeout) clearTimeout(this.leaveTimeout);
    this.hovering = false;
    this.leaveTimeout = setTimeout(() => {
      this.setHidden(true);
    }, this.delay);
  }
  _onFocusIn() {
    this.hovering = true;
    if (this.leaveTimeout) clearTimeout(this.leaveTimeout);
    this.setHidden(false);
  }
  _onFocusOut(event) {
    const nextFocusedElement = event.relatedTarget;
    if (nextFocusedElement && this.el?.contains(nextFocusedElement)) {
      return;
    }
    if (this.leaveTimeout) clearTimeout(this.leaveTimeout);
    this.hovering = false;
    this.leaveTimeout = setTimeout(() => {
      this.setHidden(true);
    }, this.delay);
  }
  _calculatePosition(data) {
    computePosition2(this.trigger, this.tooltip, {
      placement: this.placement,
      strategy: "fixed",
      middleware: [offset2(8), flip2(), shift2(), arrow2({ element: this.arrow })]
    }).then(({ x, y, strategy, middlewareData, placement }) => {
      Object.assign(this.tooltip.style, {
        left: `${x}px`,
        top: `${y}px`,
        position: strategy
      });
      if (middlewareData.arrow) {
        const { x: x2, y: y2 } = middlewareData.arrow;
        const p = placement.split("-").at(0) ?? null;
        const arrowPlacement = {
          top: "bottom",
          left: "right",
          right: "left",
          bottom: "top"
        };
        const style = {
          left: x2 != null ? `${x2}px` : "",
          top: y2 != null ? `${y2}px` : ""
        };
        style[arrowPlacement[p]] = "-4px";
        Object.assign(this.arrow.style, style);
      }
    });
  }
};

// js/flash.js
import { ViewHook as ViewHook6 } from "phoenix_live_view";
var FlashGroup = class extends ViewHook6 {
  max_flashes = 3;
  flash_timeout = 5;
  #timers = /* @__PURE__ */ new Map();
  #pausedTimers = /* @__PURE__ */ new Map();
  mounted() {
    this._updateFlashList();
    this.max_flashes = this.el.dataset.maxFlashes || this.max_flashes;
    this.flash_timeout = this.el.dataset.flashTimeout || this.flash_timeout;
    this.el.addEventListener(
      "mouseenter",
      this._onContainerMouseEnter.bind(this)
    );
    this.el.addEventListener(
      "mouseleave",
      this._onContainerMouseLeave.bind(this)
    );
  }
  updated() {
    this._updateFlashList();
  }
  destroyed() {
    this.#timers.forEach((timerObj) => clearTimeout(timerObj.timer));
    this.#timers.clear();
    this.el.removeEventListener(
      "mouseenter",
      this._onContainerMouseEnter.bind(this)
    );
    this.el.removeEventListener(
      "mouseleave",
      this._onContainerMouseLeave.bind(this)
    );
  }
  _onContainerMouseEnter() {
    this._pauseAllTimers();
  }
  _onContainerMouseLeave() {
    this._resumeAllTimers();
  }
  _onClose(event) {
    const flash = event.currentTarget.closest('[role="alert"]');
    this._removeFlash(flash);
  }
  _removeFlash(flash) {
    if (this.liveSocket?.isConnected()) {
      this.pushEvent("lv:clear-flash", { value: flash.dataset.flashId });
    }
    const flashId = flash.dataset.flashId;
    if (this.#timers.has(flashId)) {
      const timerObj = this.#timers.get(flashId);
      clearTimeout(timerObj.timer);
      this.#timers.delete(flashId);
    }
    flash.style.transition = "transform 100ms ease-in-out, opacity 100ms ease-in-out";
    flash.style.transform = "scale(0.9)";
    flash.style.opacity = "0";
    const animationEndHandler = () => {
      flash.removeEventListener("transitionend", animationEndHandler);
      flash.remove();
      this._updateFlashList();
    };
    flash.addEventListener("transitionend", animationEndHandler);
  }
  _startTimerForFlash(flash) {
    const flashId = flash.dataset.flashId;
    let duration = parseInt(flash.dataset.duration);
    if (duration === -1) {
      return;
    }
    const flashTimeout = (!isNaN(duration) ? duration : this.flash_timeout) * 1e3;
    if (this.#timers.has(flashId)) {
      const existingTimer = this.#timers.get(flashId);
      clearTimeout(existingTimer.timer);
    }
    const remainingTime = this.#pausedTimers.has(flashId) ? this.#pausedTimers.get(flashId) : flashTimeout;
    const startTime = Date.now();
    const timer = setTimeout(() => {
      this._removeFlash(flash);
    }, remainingTime);
    this.#timers.set(flashId, { timer, startTime, timeout: flashTimeout });
    if (this.#pausedTimers.has(flashId)) {
      this.#pausedTimers.delete(flashId);
    }
  }
  _pauseAllTimers() {
    this.#timers.forEach((timerObj, flashId) => {
      clearTimeout(timerObj.timer);
      const elapsed = Date.now() - timerObj.startTime;
      const remainingTime = Math.max(0, timerObj.timeout - elapsed);
      this.#pausedTimers.set(flashId, remainingTime);
    });
    this.#timers.clear();
  }
  _resumeAllTimers() {
    this.#pausedTimers.forEach((remainingTime, flashId) => {
      const flash = this.el.querySelector(`[data-flash-id="${flashId}"]`);
      if (flash) {
        const duration = parseInt(flash.dataset.duration);
        if (duration !== -1) {
          const flashTimeout = (!isNaN(duration) ? duration : this.flash_timeout) * 1e3;
          const startTime = Date.now();
          const timer = setTimeout(() => {
            this._removeFlash(flash);
          }, remainingTime);
          this.#timers.set(flashId, {
            timer,
            startTime,
            timeout: flashTimeout
          });
        }
      }
    });
    this.#pausedTimers.clear();
  }
  _updateFlashList() {
    this.flash = this.el.querySelectorAll('[role="alert"]');
    const position = this.el.dataset.position;
    this.flash.forEach((flash, index) => {
      flash.dataset.index = index;
      flash.dataset.position = position;
      flash.style.setProperty("--flash-index", index);
      if (flash.phxPrivate?.["JS:ignore_attrs"] == null) {
        this.js().ignoreAttributes(flash, ["aria-*", "data-visible", "style"]);
      }
      if (index === 0 && flash.dataset.visible !== "true") {
        flash.setAttribute("aria-hidden", "true");
        flash.style.transition = "none";
        flash.style.setProperty(
          "--flash-offset-y",
          position.startsWith("bottom-") ? "200%" : "-200%"
        );
      }
      flash.dataset.visible = "true";
      const height = flash.offsetHeight;
      const offsetY = Array.from(this.flash).slice(0, index).reduce((acc, item) => acc + item.offsetHeight + 10, 0);
      flash.style.setProperty("--flash-height", `${height}px`);
      flash.setAttribute("aria-hidden", "false");
      requestAnimationFrame(() => {
        flash.style.transition = "";
        flash.style.setProperty(
          "--flash-offset-y",
          position.startsWith("bottom-") ? `${-offsetY}px` : `${offsetY}px`
        );
      });
      const closeButton = flash.querySelector("button[data-close]");
      if (closeButton?.dataset.close == "") {
        closeButton?.addEventListener("click", this._onClose.bind(this));
        closeButton.dataset.close = "true";
      }
      const flashId = flash.dataset.flashId;
      if (!this.#timers.has(flashId)) {
        this._startTimerForFlash(flash);
      }
    });
  }
};

// js/tabs.js
import { ViewHook as ViewHook7 } from "phoenix_live_view";
var Tabs = class extends ViewHook7 {
  #clickHandler;
  #keyDownHandler;
  #focusHandler;
  mounted() {
    this.cacheElements();
    this.bindEventListeners();
    this.syncFromRootDataset();
  }
  updated() {
    const previousTabs = this.tabs;
    this.cacheElements();
    this.rebindEventListeners(previousTabs);
    this.syncFromRootDataset();
  }
  destroyed() {
    this.unbindEventListeners(this.tabs);
  }
  cacheElements() {
    this.tabs = Array.from(this.el.querySelectorAll("[role='tab']"));
    this.panels = Array.from(this.el.querySelectorAll("[role='tabpanel']"));
    this.orientation = this.el.dataset.orientation || "horizontal";
    this.activationMode = this.el.dataset.activationMode || "automatic";
    this.clientControlled = this.el.dataset.clientControlled !== "false";
  }
  bindEventListeners() {
    this.#clickHandler = this.handleClick.bind(this);
    this.#keyDownHandler = this.handleKeyDown.bind(this);
    this.#focusHandler = this.handleFocus.bind(this);
    this.tabs.forEach((tab) => {
      tab.addEventListener("click", this.#clickHandler);
      tab.addEventListener("keydown", this.#keyDownHandler);
      tab.addEventListener("focus", this.#focusHandler);
    });
  }
  unbindEventListeners(tabs) {
    tabs?.forEach((tab) => {
      tab.removeEventListener("click", this.#clickHandler);
      tab.removeEventListener("keydown", this.#keyDownHandler);
      tab.removeEventListener("focus", this.#focusHandler);
    });
  }
  rebindEventListeners(previousTabs) {
    if (previousTabs && previousTabs.length === this.tabs.length && previousTabs.every((tab, index) => tab === this.tabs[index])) {
      return;
    }
    this.unbindEventListeners(previousTabs);
    this.bindEventListeners();
  }
  handleClick(event) {
    const tab = event.currentTarget;
    if (!this.clientControlled || this.isDisabled(tab)) {
      return;
    }
    this.activateTab(tab, { focus: false });
  }
  handleFocus(event) {
    if (!this.clientControlled || this.activationMode !== "automatic") {
      return;
    }
    const tab = event.currentTarget;
    if (this.isDisabled(tab)) {
      return;
    }
    this.activateTab(tab, { focus: false });
  }
  handleKeyDown(event) {
    const currentTab = event.currentTarget;
    const enabledTabs = this.enabledTabs();
    if (enabledTabs.length === 0) {
      return;
    }
    switch (event.key) {
      case "ArrowRight":
        if (this.orientation !== "horizontal") return;
        event.preventDefault();
        this.moveFocus(currentTab, enabledTabs, 1);
        break;
      case "ArrowLeft":
        if (this.orientation !== "horizontal") return;
        event.preventDefault();
        this.moveFocus(currentTab, enabledTabs, -1);
        break;
      case "ArrowDown":
        if (this.orientation !== "vertical") return;
        event.preventDefault();
        this.moveFocus(currentTab, enabledTabs, 1);
        break;
      case "ArrowUp":
        if (this.orientation !== "vertical") return;
        event.preventDefault();
        this.moveFocus(currentTab, enabledTabs, -1);
        break;
      case "Home":
        event.preventDefault();
        this.focusTab(enabledTabs[0]);
        break;
      case "End":
        event.preventDefault();
        this.focusTab(enabledTabs[enabledTabs.length - 1]);
        break;
      case "Enter":
      case " ":
        if (!this.clientControlled) return;
        event.preventDefault();
        this.activateTab(currentTab);
        break;
    }
  }
  moveFocus(currentTab, enabledTabs, delta) {
    const currentIndex = enabledTabs.findIndex((tab) => tab === currentTab);
    const nextIndex = (currentIndex + delta + enabledTabs.length) % enabledTabs.length;
    this.focusTab(enabledTabs[nextIndex]);
  }
  focusTab(tab) {
    if (!tab) {
      return;
    }
    tab.focus();
    if (this.clientControlled && this.activationMode === "automatic") {
      this.activateTab(tab, { focus: false });
    }
  }
  activateTab(tab, options = {}) {
    const value = tab?.dataset.value;
    if (!value) {
      return;
    }
    this.el.dataset.value = value;
    this.tabs.forEach((item) => {
      const selected = item === tab;
      item.setAttribute("aria-selected", String(selected));
      item.setAttribute("data-state", selected ? "active" : "inactive");
      item.setAttribute("tabindex", selected ? "0" : "-1");
    });
    this.panels.forEach((panel) => {
      const selected = panel.dataset.value === value;
      panel.setAttribute("data-state", selected ? "active" : "inactive");
      panel.hidden = !selected;
    });
    if (options.focus !== false) {
      tab.focus();
    }
  }
  syncFromRootDataset() {
    const value = this.el.dataset.value || this.el.dataset.defaultValue || this.enabledTabs()[0]?.dataset.value;
    const activeTab = this.tabs.find((tab) => tab.dataset.value === value) || this.enabledTabs()[0];
    if (activeTab) {
      this.activateTab(activeTab, { focus: false });
      return;
    }
    this.tabs.forEach((tab) => {
      tab.setAttribute("aria-selected", "false");
      tab.setAttribute("data-state", "inactive");
      tab.setAttribute("tabindex", "-1");
    });
    this.panels.forEach((panel) => {
      panel.setAttribute("data-state", "inactive");
      panel.hidden = true;
    });
  }
  enabledTabs() {
    return this.tabs.filter((tab) => !this.isDisabled(tab));
  }
  isDisabled(tab) {
    return tab?.disabled || tab?.dataset.disabled === "true";
  }
};

// js/sidebar.js
var Sidebar = {
  mounted() {
    if (this.el.dataset.target) {
      this.initMenuItem();
    } else {
      this.initShell();
    }
  },
  updated() {
    if (this.el.dataset.target) {
      this.syncMenuItem(this.el.dataset.expanded !== "false");
    } else {
      this.syncShell(this.el.dataset.collapsed === "true");
    }
  },
  destroyed() {
    if (this.trigger && this.onClick) {
      this.trigger.removeEventListener("click", this.onClick);
    }
    if (this.toggleButton && this.onToggleClick) {
      this.toggleButton.removeEventListener("click", this.onToggleClick);
    }
  },
  initMenuItem() {
    this.targetId = this.el.dataset.target;
    this.trigger = this.el.querySelector("button");
    this.chevron = this.el.querySelector(".sidebar-collapsible-chevron");
    this.onClick = () => this.toggleMenuItem();
    this.syncMenuItem(this.el.dataset.expanded !== "false");
    if (this.trigger) this.trigger.addEventListener("click", this.onClick);
  },
  initShell() {
    this.toggleButton = document.getElementById(`${this.el.id}-sidebar-collapse-toggle`);
    this.onToggleClick = () => this.toggleShell();
    this.syncShell(this.el.dataset.collapsed === "true");
    if (this.toggleButton) {
      this.toggleButton.addEventListener("click", this.onToggleClick);
    }
  },
  toggleMenuItem() {
    const expanded = this.el.dataset.expanded !== "false";
    this.syncMenuItem(!expanded);
  },
  toggleShell() {
    const collapsed = this.el.dataset.collapsed === "true";
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        this.syncShell(!collapsed);
      });
    });
  },
  syncMenuItem(expanded) {
    const value = expanded ? "true" : "false";
    const target = this.targetId ? document.getElementById(this.targetId) : null;
    this.el.dataset.expanded = value;
    if (this.trigger) this.trigger.setAttribute("aria-expanded", value);
    if (this.chevron) this.chevron.dataset.expanded = value;
    if (target) {
      target.dataset.expanded = value;
      target.setAttribute("aria-hidden", expanded ? "false" : "true");
    }
  },
  syncShell(collapsed) {
    this.el.dataset.collapsed = collapsed ? "true" : "false";
  }
};
var sidebar_default = Sidebar;

// js/chart_hook.js
import { ViewHook as ViewHook8 } from "phoenix_live_view";

// node_modules/uplot/dist/uPlot.esm.js
var FEAT_TIME = true;
var pre = "u-";
var UPLOT = "uplot";
var ORI_HZ = pre + "hz";
var ORI_VT = pre + "vt";
var TITLE = pre + "title";
var WRAP = pre + "wrap";
var UNDER = pre + "under";
var OVER = pre + "over";
var AXIS = pre + "axis";
var OFF = pre + "off";
var SELECT = pre + "select";
var CURSOR_X = pre + "cursor-x";
var CURSOR_Y = pre + "cursor-y";
var CURSOR_PT = pre + "cursor-pt";
var LEGEND = pre + "legend";
var LEGEND_LIVE = pre + "live";
var LEGEND_INLINE = pre + "inline";
var LEGEND_SERIES = pre + "series";
var LEGEND_MARKER = pre + "marker";
var LEGEND_LABEL = pre + "label";
var LEGEND_VALUE = pre + "value";
var WIDTH = "width";
var HEIGHT = "height";
var TOP = "top";
var BOTTOM = "bottom";
var LEFT = "left";
var RIGHT = "right";
var hexBlack = "#000";
var transparent = hexBlack + "0";
var mousemove = "mousemove";
var mousedown = "mousedown";
var mouseup = "mouseup";
var mouseenter = "mouseenter";
var mouseleave = "mouseleave";
var dblclick = "dblclick";
var resize = "resize";
var scroll = "scroll";
var change = "change";
var dppxchange = "dppxchange";
var LEGEND_DISP = "--";
var domEnv = typeof window != "undefined";
var doc = domEnv ? document : null;
var win = domEnv ? window : null;
var nav = domEnv ? navigator : null;
var pxRatio;
var query;
function setPxRatio() {
  let _pxRatio = devicePixelRatio;
  if (pxRatio != _pxRatio) {
    pxRatio = _pxRatio;
    query && off(change, query, setPxRatio);
    query = matchMedia(`(min-resolution: ${pxRatio - 1e-3}dppx) and (max-resolution: ${pxRatio + 1e-3}dppx)`);
    on(change, query, setPxRatio);
    win.dispatchEvent(new CustomEvent(dppxchange));
  }
}
function addClass(el, c) {
  if (c != null) {
    let cl = el.classList;
    !cl.contains(c) && cl.add(c);
  }
}
function remClass(el, c) {
  let cl = el.classList;
  cl.contains(c) && cl.remove(c);
}
function setStylePx(el, name, value) {
  el.style[name] = value + "px";
}
function placeTag(tag, cls, targ, refEl) {
  let el = doc.createElement(tag);
  if (cls != null)
    addClass(el, cls);
  if (targ != null)
    targ.insertBefore(el, refEl);
  return el;
}
function placeDiv(cls, targ) {
  return placeTag("div", cls, targ);
}
var xformCache = /* @__PURE__ */ new WeakMap();
function elTrans(el, xPos, yPos, xMax, yMax) {
  let xform = "translate(" + xPos + "px," + yPos + "px)";
  let xformOld = xformCache.get(el);
  if (xform != xformOld) {
    el.style.transform = xform;
    xformCache.set(el, xform);
    if (xPos < 0 || yPos < 0 || xPos > xMax || yPos > yMax)
      addClass(el, OFF);
    else
      remClass(el, OFF);
  }
}
var colorCache = /* @__PURE__ */ new WeakMap();
function elColor(el, background, borderColor) {
  let newColor = background + borderColor;
  let oldColor = colorCache.get(el);
  if (newColor != oldColor) {
    colorCache.set(el, newColor);
    el.style.background = background;
    el.style.borderColor = borderColor;
  }
}
var sizeCache = /* @__PURE__ */ new WeakMap();
function elSize(el, newWid, newHgt, centered) {
  let newSize = newWid + "" + newHgt;
  let oldSize = sizeCache.get(el);
  if (newSize != oldSize) {
    sizeCache.set(el, newSize);
    el.style.height = newHgt + "px";
    el.style.width = newWid + "px";
    el.style.marginLeft = centered ? -newWid / 2 + "px" : 0;
    el.style.marginTop = centered ? -newHgt / 2 + "px" : 0;
  }
}
var evOpts = { passive: true };
var evOpts2 = { ...evOpts, capture: true };
function on(ev, el, cb, capt) {
  el.addEventListener(ev, cb, capt ? evOpts2 : evOpts);
}
function off(ev, el, cb, capt) {
  el.removeEventListener(ev, cb, evOpts);
}
domEnv && setPxRatio();
function closestIdx(num, arr, lo, hi) {
  let mid;
  lo = lo || 0;
  hi = hi || arr.length - 1;
  let bitwise = hi <= 2147483647;
  while (hi - lo > 1) {
    mid = bitwise ? lo + hi >> 1 : floor2((lo + hi) / 2);
    if (arr[mid] < num)
      lo = mid;
    else
      hi = mid;
  }
  if (num - arr[lo] <= arr[hi] - num)
    return lo;
  return hi;
}
function makeIndexOfs(predicate) {
  let indexOfs = (data, _i0, _i1) => {
    let i0 = -1;
    let i1 = -1;
    for (let i = _i0; i <= _i1; i++) {
      if (predicate(data[i])) {
        i0 = i;
        break;
      }
    }
    for (let i = _i1; i >= _i0; i--) {
      if (predicate(data[i])) {
        i1 = i;
        break;
      }
    }
    return [i0, i1];
  };
  return indexOfs;
}
var notNullish = (v) => v != null;
var isPositive = (v) => v != null && v > 0;
var nonNullIdxs = makeIndexOfs(notNullish);
var positiveIdxs = makeIndexOfs(isPositive);
function getMinMax(data, _i0, _i1, sorted = 0, log = false) {
  let getEdgeIdxs = log ? positiveIdxs : nonNullIdxs;
  let predicate = log ? isPositive : notNullish;
  [_i0, _i1] = getEdgeIdxs(data, _i0, _i1);
  let _min = data[_i0];
  let _max = data[_i0];
  if (_i0 > -1) {
    if (sorted == 1) {
      _min = data[_i0];
      _max = data[_i1];
    } else if (sorted == -1) {
      _min = data[_i1];
      _max = data[_i0];
    } else {
      for (let i = _i0; i <= _i1; i++) {
        let v = data[i];
        if (predicate(v)) {
          if (v < _min)
            _min = v;
          else if (v > _max)
            _max = v;
        }
      }
    }
  }
  return [_min ?? inf, _max ?? -inf];
}
function rangeLog(min3, max3, base, fullMags) {
  let minSign = sign(min3);
  let maxSign = sign(max3);
  if (min3 == max3) {
    if (minSign == -1) {
      min3 *= base;
      max3 /= base;
    } else {
      min3 /= base;
      max3 *= base;
    }
  }
  let logFn = base == 10 ? log10 : log2;
  let growMinAbs = minSign == 1 ? floor2 : ceil;
  let growMaxAbs = maxSign == 1 ? ceil : floor2;
  let minExp = growMinAbs(logFn(abs(min3)));
  let maxExp = growMaxAbs(logFn(abs(max3)));
  let minIncr = pow(base, minExp);
  let maxIncr = pow(base, maxExp);
  if (base == 10) {
    if (minExp < 0)
      minIncr = roundDec(minIncr, -minExp);
    if (maxExp < 0)
      maxIncr = roundDec(maxIncr, -maxExp);
  }
  if (fullMags || base == 2) {
    min3 = minIncr * minSign;
    max3 = maxIncr * maxSign;
  } else {
    min3 = incrRoundDn(min3, minIncr);
    max3 = incrRoundUp(max3, maxIncr);
  }
  return [min3, max3];
}
function rangeAsinh(min3, max3, base, fullMags) {
  let minMax = rangeLog(min3, max3, base, fullMags);
  if (min3 == 0)
    minMax[0] = 0;
  if (max3 == 0)
    minMax[1] = 0;
  return minMax;
}
var rangePad = 0.1;
var autoRangePart = {
  mode: 3,
  pad: rangePad
};
var _eqRangePart = {
  pad: 0,
  soft: null,
  mode: 0
};
var _eqRange = {
  min: _eqRangePart,
  max: _eqRangePart
};
function rangeNum(_min, _max, mult, extra) {
  if (isObj(mult))
    return _rangeNum(_min, _max, mult);
  _eqRangePart.pad = mult;
  _eqRangePart.soft = extra ? 0 : null;
  _eqRangePart.mode = extra ? 3 : 0;
  return _rangeNum(_min, _max, _eqRange);
}
function ifNull(lh, rh) {
  return lh == null ? rh : lh;
}
function hasData(data, idx0, idx1) {
  idx0 = ifNull(idx0, 0);
  idx1 = ifNull(idx1, data.length - 1);
  while (idx0 <= idx1) {
    if (data[idx0] != null)
      return true;
    idx0++;
  }
  return false;
}
function _rangeNum(_min, _max, cfg) {
  let cmin = cfg.min;
  let cmax = cfg.max;
  let padMin = ifNull(cmin.pad, 0);
  let padMax = ifNull(cmax.pad, 0);
  let hardMin = ifNull(cmin.hard, -inf);
  let hardMax = ifNull(cmax.hard, inf);
  let softMin = ifNull(cmin.soft, inf);
  let softMax = ifNull(cmax.soft, -inf);
  let softMinMode = ifNull(cmin.mode, 0);
  let softMaxMode = ifNull(cmax.mode, 0);
  let delta = _max - _min;
  let deltaMag = log10(delta);
  let scalarMax = max2(abs(_min), abs(_max));
  let scalarMag = log10(scalarMax);
  let scalarMagDelta = abs(scalarMag - deltaMag);
  if (delta < 1e-24 || scalarMagDelta > 10) {
    delta = 0;
    if (_min == 0 || _max == 0) {
      delta = 1e-24;
      if (softMinMode == 2 && softMin != inf)
        padMin = 0;
      if (softMaxMode == 2 && softMax != -inf)
        padMax = 0;
    }
  }
  let nonZeroDelta = delta || scalarMax || 1e3;
  let mag = log10(nonZeroDelta);
  let base = pow(10, floor2(mag));
  let _padMin = nonZeroDelta * (delta == 0 ? _min == 0 ? 0.1 : 1 : padMin);
  let _newMin = roundDec(incrRoundDn(_min - _padMin, base / 10), 24);
  let _softMin = _min >= softMin && (softMinMode == 1 || softMinMode == 3 && _newMin <= softMin || softMinMode == 2 && _newMin >= softMin) ? softMin : inf;
  let minLim = max2(hardMin, _newMin < _softMin && _min >= _softMin ? _softMin : min2(_softMin, _newMin));
  let _padMax = nonZeroDelta * (delta == 0 ? _max == 0 ? 0.1 : 1 : padMax);
  let _newMax = roundDec(incrRoundUp(_max + _padMax, base / 10), 24);
  let _softMax = _max <= softMax && (softMaxMode == 1 || softMaxMode == 3 && _newMax >= softMax || softMaxMode == 2 && _newMax <= softMax) ? softMax : -inf;
  let maxLim = min2(hardMax, _newMax > _softMax && _max <= _softMax ? _softMax : max2(_softMax, _newMax));
  if (minLim == maxLim && minLim == 0)
    maxLim = 100;
  return [minLim, maxLim];
}
var numFormatter = new Intl.NumberFormat(domEnv ? nav.language : "en-US");
var fmtNum = (val) => numFormatter.format(val);
var M = Math;
var PI = M.PI;
var abs = M.abs;
var floor2 = M.floor;
var round2 = M.round;
var ceil = M.ceil;
var min2 = M.min;
var max2 = M.max;
var pow = M.pow;
var sign = M.sign;
var log10 = M.log10;
var log2 = M.log2;
var sinh = (v, linthresh = 1) => M.sinh(v) * linthresh;
var asinh = (v, linthresh = 1) => M.asinh(v / linthresh);
var inf = Infinity;
function numIntDigits(x) {
  return (log10((x ^ x >> 31) - (x >> 31)) | 0) + 1;
}
function clamp2(num, _min, _max) {
  return min2(max2(num, _min), _max);
}
function isFn(v) {
  return typeof v == "function";
}
function fnOrSelf(v) {
  return isFn(v) ? v : () => v;
}
var noop = () => {
};
var retArg0 = (_0) => _0;
var retArg1 = (_0, _1) => _1;
var retNull = (_2) => null;
var retTrue = (_2) => true;
var retEq = (a, b) => a == b;
var regex6 = /\.\d*?(?=9{6,}|0{6,})/gm;
var fixFloat = (val) => {
  if (isInt(val) || fixedDec.has(val))
    return val;
  const str = `${val}`;
  const match = str.match(regex6);
  if (match == null)
    return val;
  let len = match[0].length - 1;
  if (str.indexOf("e-") != -1) {
    let [num, exp] = str.split("e");
    return +`${fixFloat(num)}e${exp}`;
  }
  return roundDec(val, len);
};
function incrRound(num, incr) {
  return fixFloat(roundDec(fixFloat(num / incr)) * incr);
}
function incrRoundUp(num, incr) {
  return fixFloat(ceil(fixFloat(num / incr)) * incr);
}
function incrRoundDn(num, incr) {
  return fixFloat(floor2(fixFloat(num / incr)) * incr);
}
function roundDec(val, dec = 0) {
  if (isInt(val))
    return val;
  let p = 10 ** dec;
  let n = val * p * (1 + Number.EPSILON);
  return round2(n) / p;
}
var fixedDec = /* @__PURE__ */ new Map();
function guessDec(num) {
  return (("" + num).split(".")[1] || "").length;
}
function genIncrs(base, minExp, maxExp, mults) {
  let incrs = [];
  let multDec = mults.map(guessDec);
  for (let exp = minExp; exp < maxExp; exp++) {
    let expa = abs(exp);
    let mag = roundDec(pow(base, exp), expa);
    for (let i = 0; i < mults.length; i++) {
      let _incr = base == 10 ? +`${mults[i]}e${exp}` : mults[i] * mag;
      let dec = (exp >= 0 ? 0 : expa) + (exp >= multDec[i] ? 0 : multDec[i]);
      let incr = base == 10 ? _incr : roundDec(_incr, dec);
      incrs.push(incr);
      fixedDec.set(incr, dec);
    }
  }
  return incrs;
}
var EMPTY_OBJ = {};
var EMPTY_ARR = [];
var nullNullTuple = [null, null];
var isArr = Array.isArray;
var isInt = Number.isInteger;
var isUndef = (v) => v === void 0;
function isStr(v) {
  return typeof v == "string";
}
function isObj(v) {
  let is = false;
  if (v != null) {
    let c = v.constructor;
    is = c == null || c == Object;
  }
  return is;
}
function fastIsObj(v) {
  return v != null && typeof v == "object";
}
var TypedArray = Object.getPrototypeOf(Uint8Array);
var __proto__ = "__proto__";
function copy(o, _isObj = isObj) {
  let out;
  if (isArr(o)) {
    let val = o.find((v) => v != null);
    if (isArr(val) || _isObj(val)) {
      out = Array(o.length);
      for (let i = 0; i < o.length; i++)
        out[i] = copy(o[i], _isObj);
    } else
      out = o.slice();
  } else if (o instanceof TypedArray)
    out = o.slice();
  else if (_isObj(o)) {
    out = {};
    for (let k in o) {
      if (k != __proto__)
        out[k] = copy(o[k], _isObj);
    }
  } else
    out = o;
  return out;
}
function assign(targ) {
  let args = arguments;
  for (let i = 1; i < args.length; i++) {
    let src = args[i];
    for (let key in src) {
      if (key != __proto__) {
        if (isObj(targ[key]))
          assign(targ[key], copy(src[key]));
        else
          targ[key] = copy(src[key]);
      }
    }
  }
  return targ;
}
var NULL_REMOVE = 0;
var NULL_RETAIN = 1;
var NULL_EXPAND = 2;
function nullExpand(yVals, nullIdxs, alignedLen) {
  for (let i = 0, xi, lastNullIdx = -1; i < nullIdxs.length; i++) {
    let nullIdx = nullIdxs[i];
    if (nullIdx > lastNullIdx) {
      xi = nullIdx - 1;
      while (xi >= 0 && yVals[xi] == null)
        yVals[xi--] = null;
      xi = nullIdx + 1;
      while (xi < alignedLen && yVals[xi] == null)
        yVals[lastNullIdx = xi++] = null;
    }
  }
}
function join(tables, nullModes) {
  if (allHeadersSame(tables)) {
    let table = tables[0].slice();
    for (let i = 1; i < tables.length; i++)
      table.push(...tables[i].slice(1));
    if (!isAsc(table[0]))
      table = sortCols(table);
    return table;
  }
  let xVals = /* @__PURE__ */ new Set();
  for (let ti = 0; ti < tables.length; ti++) {
    let t = tables[ti];
    let xs = t[0];
    let len = xs.length;
    for (let i = 0; i < len; i++)
      xVals.add(xs[i]);
  }
  let data = [Array.from(xVals).sort((a, b) => a - b)];
  let alignedLen = data[0].length;
  let xIdxs = /* @__PURE__ */ new Map();
  for (let i = 0; i < alignedLen; i++)
    xIdxs.set(data[0][i], i);
  for (let ti = 0; ti < tables.length; ti++) {
    let t = tables[ti];
    let xs = t[0];
    for (let si = 1; si < t.length; si++) {
      let ys = t[si];
      let yVals = Array(alignedLen).fill(void 0);
      let nullMode = nullModes ? nullModes[ti][si] : NULL_RETAIN;
      let nullIdxs = [];
      for (let i = 0; i < ys.length; i++) {
        let yVal = ys[i];
        let alignedIdx = xIdxs.get(xs[i]);
        if (yVal === null) {
          if (nullMode != NULL_REMOVE) {
            yVals[alignedIdx] = yVal;
            if (nullMode == NULL_EXPAND)
              nullIdxs.push(alignedIdx);
          }
        } else
          yVals[alignedIdx] = yVal;
      }
      nullExpand(yVals, nullIdxs, alignedLen);
      data.push(yVals);
    }
  }
  return data;
}
var microTask = typeof queueMicrotask == "undefined" ? (fn) => Promise.resolve().then(fn) : queueMicrotask;
function sortCols(table) {
  let head = table[0];
  let rlen = head.length;
  let idxs = Array(rlen);
  for (let i = 0; i < idxs.length; i++)
    idxs[i] = i;
  idxs.sort((i0, i1) => head[i0] - head[i1]);
  let table2 = [];
  for (let i = 0; i < table.length; i++) {
    let row = table[i];
    let row2 = Array(rlen);
    for (let j = 0; j < rlen; j++)
      row2[j] = row[idxs[j]];
    table2.push(row2);
  }
  return table2;
}
function allHeadersSame(tables) {
  let vals0 = tables[0][0];
  let len0 = vals0.length;
  for (let i = 1; i < tables.length; i++) {
    let vals1 = tables[i][0];
    if (vals1.length != len0)
      return false;
    if (vals1 != vals0) {
      for (let j = 0; j < len0; j++) {
        if (vals1[j] != vals0[j])
          return false;
      }
    }
  }
  return true;
}
function isAsc(vals, samples = 100) {
  const len = vals.length;
  if (len <= 1)
    return true;
  let firstIdx = 0;
  let lastIdx = len - 1;
  while (firstIdx <= lastIdx && vals[firstIdx] == null)
    firstIdx++;
  while (lastIdx >= firstIdx && vals[lastIdx] == null)
    lastIdx--;
  if (lastIdx <= firstIdx)
    return true;
  const stride = max2(1, floor2((lastIdx - firstIdx + 1) / samples));
  for (let prevVal = vals[firstIdx], i = firstIdx + stride; i <= lastIdx; i += stride) {
    const v = vals[i];
    if (v != null) {
      if (v <= prevVal)
        return false;
      prevVal = v;
    }
  }
  return true;
}
var months = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December"
];
var days = [
  "Sunday",
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday"
];
function slice3(str) {
  return str.slice(0, 3);
}
var days3 = days.map(slice3);
var months3 = months.map(slice3);
var engNames = {
  MMMM: months,
  MMM: months3,
  WWWW: days,
  WWW: days3
};
function zeroPad2(int) {
  return (int < 10 ? "0" : "") + int;
}
function zeroPad3(int) {
  return (int < 10 ? "00" : int < 100 ? "0" : "") + int;
}
var subs = {
  // 2019
  YYYY: (d) => d.getFullYear(),
  // 19
  YY: (d) => (d.getFullYear() + "").slice(2),
  // July
  MMMM: (d, names) => names.MMMM[d.getMonth()],
  // Jul
  MMM: (d, names) => names.MMM[d.getMonth()],
  // 07
  MM: (d) => zeroPad2(d.getMonth() + 1),
  // 7
  M: (d) => d.getMonth() + 1,
  // 09
  DD: (d) => zeroPad2(d.getDate()),
  // 9
  D: (d) => d.getDate(),
  // Monday
  WWWW: (d, names) => names.WWWW[d.getDay()],
  // Mon
  WWW: (d, names) => names.WWW[d.getDay()],
  // 03
  HH: (d) => zeroPad2(d.getHours()),
  // 3
  H: (d) => d.getHours(),
  // 9 (12hr, unpadded)
  h: (d) => {
    let h = d.getHours();
    return h == 0 ? 12 : h > 12 ? h - 12 : h;
  },
  // AM
  AA: (d) => d.getHours() >= 12 ? "PM" : "AM",
  // am
  aa: (d) => d.getHours() >= 12 ? "pm" : "am",
  // a
  a: (d) => d.getHours() >= 12 ? "p" : "a",
  // 09
  mm: (d) => zeroPad2(d.getMinutes()),
  // 9
  m: (d) => d.getMinutes(),
  // 09
  ss: (d) => zeroPad2(d.getSeconds()),
  // 9
  s: (d) => d.getSeconds(),
  // 374
  fff: (d) => zeroPad3(d.getMilliseconds())
};
function fmtDate(tpl, names) {
  names = names || engNames;
  let parts = [];
  let R = /\{([a-z]+)\}|[^{]+/gi, m;
  while (m = R.exec(tpl))
    parts.push(m[0][0] == "{" ? subs[m[1]] : m[0]);
  return (d) => {
    let out = "";
    for (let i = 0; i < parts.length; i++)
      out += typeof parts[i] == "string" ? parts[i] : parts[i](d, names);
    return out;
  };
}
var localTz = new Intl.DateTimeFormat().resolvedOptions().timeZone;
function tzDate(date, tz) {
  let date2;
  if (tz == "UTC" || tz == "Etc/UTC")
    date2 = new Date(+date + date.getTimezoneOffset() * 6e4);
  else if (tz == localTz)
    date2 = date;
  else {
    date2 = new Date(date.toLocaleString("en-US", { timeZone: tz }));
    date2.setMilliseconds(date.getMilliseconds());
  }
  return date2;
}
var onlyWhole = (v) => v % 1 == 0;
var allMults = [1, 2, 2.5, 5];
var decIncrs = genIncrs(10, -32, 0, allMults);
var oneIncrs = genIncrs(10, 0, 32, allMults);
var wholeIncrs = oneIncrs.filter(onlyWhole);
var numIncrs = decIncrs.concat(oneIncrs);
var NL = "\n";
var yyyy = "{YYYY}";
var NLyyyy = NL + yyyy;
var md = "{M}/{D}";
var NLmd = NL + md;
var NLmdyy = NLmd + "/{YY}";
var aa = "{aa}";
var hmm = "{h}:{mm}";
var hmmaa = hmm + aa;
var NLhmmaa = NL + hmmaa;
var ss = ":{ss}";
var _ = null;
function genTimeStuffs(ms) {
  let s = ms * 1e3, m = s * 60, h = m * 60, d = h * 24, mo = d * 30, y = d * 365;
  let subSecIncrs = ms == 1 ? genIncrs(10, 0, 3, allMults).filter(onlyWhole) : genIncrs(10, -3, 0, allMults);
  let timeIncrs = subSecIncrs.concat([
    // minute divisors (# of secs)
    s,
    s * 5,
    s * 10,
    s * 15,
    s * 30,
    // hour divisors (# of mins)
    m,
    m * 5,
    m * 10,
    m * 15,
    m * 30,
    // day divisors (# of hrs)
    h,
    h * 2,
    h * 3,
    h * 4,
    h * 6,
    h * 8,
    h * 12,
    // month divisors TODO: need more?
    d,
    d * 2,
    d * 3,
    d * 4,
    d * 5,
    d * 6,
    d * 7,
    d * 8,
    d * 9,
    d * 10,
    d * 15,
    // year divisors (# months, approx)
    mo,
    mo * 2,
    mo * 3,
    mo * 4,
    mo * 6,
    // century divisors
    y,
    y * 2,
    y * 5,
    y * 10,
    y * 25,
    y * 50,
    y * 100
  ]);
  const _timeAxisStamps = [
    //   tick incr    default          year                    month   day                   hour    min       sec   mode
    [y, yyyy, _, _, _, _, _, _, 1],
    [d * 28, "{MMM}", NLyyyy, _, _, _, _, _, 1],
    [d, md, NLyyyy, _, _, _, _, _, 1],
    [h, "{h}" + aa, NLmdyy, _, NLmd, _, _, _, 1],
    [m, hmmaa, NLmdyy, _, NLmd, _, _, _, 1],
    [s, ss, NLmdyy + " " + hmmaa, _, NLmd + " " + hmmaa, _, NLhmmaa, _, 1],
    [ms, ss + ".{fff}", NLmdyy + " " + hmmaa, _, NLmd + " " + hmmaa, _, NLhmmaa, _, 1]
  ];
  function timeAxisSplits(tzDate2) {
    return (self, axisIdx, scaleMin, scaleMax, foundIncr, foundSpace) => {
      let splits = [];
      let isYr = foundIncr >= y;
      let isMo = foundIncr >= mo && foundIncr < y;
      let minDate = tzDate2(scaleMin);
      let minDateTs = roundDec(minDate * ms, 3);
      let minMin = mkDate(minDate.getFullYear(), isYr ? 0 : minDate.getMonth(), isMo || isYr ? 1 : minDate.getDate());
      let minMinTs = roundDec(minMin * ms, 3);
      if (isMo || isYr) {
        let moIncr = isMo ? foundIncr / mo : 0;
        let yrIncr = isYr ? foundIncr / y : 0;
        let split = minDateTs == minMinTs ? minDateTs : roundDec(mkDate(minMin.getFullYear() + yrIncr, minMin.getMonth() + moIncr, 1) * ms, 3);
        let splitDate = new Date(round2(split / ms));
        let baseYear = splitDate.getFullYear();
        let baseMonth = splitDate.getMonth();
        for (let i = 0; split <= scaleMax; i++) {
          let next = mkDate(baseYear + yrIncr * i, baseMonth + moIncr * i, 1);
          let offs = next - tzDate2(roundDec(next * ms, 3));
          split = roundDec((+next + offs) * ms, 3);
          if (split <= scaleMax)
            splits.push(split);
        }
      } else {
        let incr0 = foundIncr >= d ? d : foundIncr;
        let tzOffset = floor2(scaleMin) - floor2(minDateTs);
        let split = minMinTs + tzOffset + incrRoundUp(minDateTs - minMinTs, incr0);
        splits.push(split);
        let date0 = tzDate2(split);
        let prevHour = date0.getHours() + date0.getMinutes() / m + date0.getSeconds() / h;
        let incrHours = foundIncr / h;
        let minSpace = self.axes[axisIdx]._space;
        let pctSpace = foundSpace / minSpace;
        while (1) {
          split = roundDec(split + foundIncr, ms == 1 ? 0 : 3);
          if (split > scaleMax)
            break;
          if (incrHours > 1) {
            let expectedHour = floor2(roundDec(prevHour + incrHours, 6)) % 24;
            let splitDate = tzDate2(split);
            let actualHour = splitDate.getHours();
            let dstShift = actualHour - expectedHour;
            if (dstShift > 1)
              dstShift = -1;
            split -= dstShift * h;
            prevHour = (prevHour + incrHours) % 24;
            let prevSplit = splits[splits.length - 1];
            let pctIncr = roundDec((split - prevSplit) / foundIncr, 3);
            if (pctIncr * pctSpace >= 0.7)
              splits.push(split);
          } else
            splits.push(split);
        }
      }
      return splits;
    };
  }
  return [
    timeIncrs,
    _timeAxisStamps,
    timeAxisSplits
  ];
}
var [timeIncrsMs, _timeAxisStampsMs, timeAxisSplitsMs] = genTimeStuffs(1);
var [timeIncrsS, _timeAxisStampsS, timeAxisSplitsS] = genTimeStuffs(1e-3);
genIncrs(2, -53, 53, [1]);
function timeAxisStamps(stampCfg, fmtDate2) {
  return stampCfg.map((s) => s.map(
    (v, i) => i == 0 || i == 8 || v == null ? v : fmtDate2(i == 1 || s[8] == 0 ? v : s[1] + v)
  ));
}
function timeAxisVals(tzDate2, stamps) {
  return (self, splits, axisIdx, foundSpace, foundIncr) => {
    let s = stamps.find((s2) => foundIncr >= s2[0]) || stamps[stamps.length - 1];
    let prevYear;
    let prevMnth;
    let prevDate;
    let prevHour;
    let prevMins;
    let prevSecs;
    return splits.map((split) => {
      let date = tzDate2(split);
      let newYear = date.getFullYear();
      let newMnth = date.getMonth();
      let newDate = date.getDate();
      let newHour = date.getHours();
      let newMins = date.getMinutes();
      let newSecs = date.getSeconds();
      let stamp = newYear != prevYear && s[2] || newMnth != prevMnth && s[3] || newDate != prevDate && s[4] || newHour != prevHour && s[5] || newMins != prevMins && s[6] || newSecs != prevSecs && s[7] || s[1];
      prevYear = newYear;
      prevMnth = newMnth;
      prevDate = newDate;
      prevHour = newHour;
      prevMins = newMins;
      prevSecs = newSecs;
      return stamp(date);
    });
  };
}
function timeAxisVal(tzDate2, dateTpl) {
  let stamp = fmtDate(dateTpl);
  return (self, splits, axisIdx, foundSpace, foundIncr) => splits.map((split) => stamp(tzDate2(split)));
}
function mkDate(y, m, d) {
  return new Date(y, m, d);
}
function timeSeriesStamp(stampCfg, fmtDate2) {
  return fmtDate2(stampCfg);
}
var _timeSeriesStamp = "{YYYY}-{MM}-{DD} {h}:{mm}{aa}";
function timeSeriesVal(tzDate2, stamp) {
  return (self, val, seriesIdx, dataIdx) => dataIdx == null ? LEGEND_DISP : stamp(tzDate2(val));
}
function legendStroke(self, seriesIdx) {
  let s = self.series[seriesIdx];
  return s.width ? s.stroke(self, seriesIdx) : s.points.width ? s.points.stroke(self, seriesIdx) : null;
}
function legendFill(self, seriesIdx) {
  return self.series[seriesIdx].fill(self, seriesIdx);
}
var legendOpts = {
  show: true,
  live: true,
  isolate: false,
  mount: noop,
  markers: {
    show: true,
    width: 2,
    stroke: legendStroke,
    fill: legendFill,
    dash: "solid"
  },
  idx: null,
  idxs: null,
  values: []
};
function cursorPointShow(self, si) {
  let o = self.cursor.points;
  let pt = placeDiv();
  let size3 = o.size(self, si);
  setStylePx(pt, WIDTH, size3);
  setStylePx(pt, HEIGHT, size3);
  let mar = size3 / -2;
  setStylePx(pt, "marginLeft", mar);
  setStylePx(pt, "marginTop", mar);
  let width = o.width(self, si, size3);
  width && setStylePx(pt, "borderWidth", width);
  return pt;
}
function cursorPointFill(self, si) {
  let sp = self.series[si].points;
  return sp._fill || sp._stroke;
}
function cursorPointStroke(self, si) {
  let sp = self.series[si].points;
  return sp._stroke || sp._fill;
}
function cursorPointSize(self, si) {
  let sp = self.series[si].points;
  return sp.size;
}
var moveTuple = [0, 0];
function cursorMove(self, mouseLeft1, mouseTop1) {
  moveTuple[0] = mouseLeft1;
  moveTuple[1] = mouseTop1;
  return moveTuple;
}
function filtBtn0(self, targ, handle, onlyTarg = true) {
  return (e) => {
    e.button == 0 && (!onlyTarg || e.target == targ) && handle(e);
  };
}
function filtTarg(self, targ, handle, onlyTarg = true) {
  return (e) => {
    (!onlyTarg || e.target == targ) && handle(e);
  };
}
var cursorOpts = {
  show: true,
  x: true,
  y: true,
  lock: false,
  move: cursorMove,
  points: {
    one: false,
    show: cursorPointShow,
    size: cursorPointSize,
    width: 0,
    stroke: cursorPointStroke,
    fill: cursorPointFill
  },
  bind: {
    mousedown: filtBtn0,
    mouseup: filtBtn0,
    click: filtBtn0,
    // legend clicks, not .u-over clicks
    dblclick: filtBtn0,
    mousemove: filtTarg,
    mouseleave: filtTarg,
    mouseenter: filtTarg
  },
  drag: {
    setScale: true,
    x: true,
    y: false,
    dist: 0,
    uni: null,
    click: (self, e) => {
      e.stopPropagation();
      e.stopImmediatePropagation();
    },
    _x: false,
    _y: false
  },
  focus: {
    dist: (self, seriesIdx, dataIdx, valPos, curPos) => valPos - curPos,
    prox: -1,
    bias: 0
  },
  hover: {
    skip: [void 0],
    prox: null,
    bias: 0
  },
  left: -10,
  top: -10,
  idx: null,
  dataIdx: null,
  idxs: null,
  event: null
};
var axisLines = {
  show: true,
  stroke: "rgba(0,0,0,0.07)",
  width: 2
  //	dash: [],
};
var grid = assign({}, axisLines, {
  filter: retArg1
});
var ticks = assign({}, grid, {
  size: 10
});
var border = assign({}, axisLines, {
  show: false
});
var font = '12px system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial, "Noto Sans", sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji"';
var labelFont = "bold " + font;
var lineGap = 1.5;
var xAxisOpts = {
  show: true,
  scale: "x",
  stroke: hexBlack,
  space: 50,
  gap: 5,
  alignTo: 1,
  size: 50,
  labelGap: 0,
  labelSize: 30,
  labelFont,
  side: 2,
  //	class: "x-vals",
  //	incrs: timeIncrs,
  //	values: timeVals,
  //	filter: retArg1,
  grid,
  ticks,
  border,
  font,
  lineGap,
  rotate: 0
};
var numSeriesLabel = "Value";
var timeSeriesLabel = "Time";
var xSeriesOpts = {
  show: true,
  scale: "x",
  auto: false,
  sorted: 1,
  //	label: "Time",
  //	value: v => stamp(new Date(v * 1e3)),
  // internal caches
  min: inf,
  max: -inf,
  idxs: []
};
function numAxisVals(self, splits, axisIdx, foundSpace, foundIncr) {
  return splits.map((v) => v == null ? "" : fmtNum(v));
}
function numAxisSplits(self, axisIdx, scaleMin, scaleMax, foundIncr, foundSpace, forceMin) {
  let splits = [];
  let numDec = fixedDec.get(foundIncr) || 0;
  scaleMin = forceMin ? scaleMin : roundDec(incrRoundUp(scaleMin, foundIncr), numDec);
  for (let val = scaleMin; val <= scaleMax; val = roundDec(val + foundIncr, numDec))
    splits.push(Object.is(val, -0) ? 0 : val);
  return splits;
}
function logAxisSplits(self, axisIdx, scaleMin, scaleMax, foundIncr, foundSpace, forceMin) {
  const splits = [];
  const logBase = self.scales[self.axes[axisIdx].scale].log;
  const logFn = logBase == 10 ? log10 : log2;
  const exp = floor2(logFn(scaleMin));
  foundIncr = pow(logBase, exp);
  if (logBase == 10)
    foundIncr = numIncrs[closestIdx(foundIncr, numIncrs)];
  let split = scaleMin;
  let nextMagIncr = foundIncr * logBase;
  if (logBase == 10)
    nextMagIncr = numIncrs[closestIdx(nextMagIncr, numIncrs)];
  do {
    splits.push(split);
    split = split + foundIncr;
    if (logBase == 10 && !fixedDec.has(split))
      split = roundDec(split, fixedDec.get(foundIncr));
    if (split >= nextMagIncr) {
      foundIncr = split;
      nextMagIncr = foundIncr * logBase;
      if (logBase == 10)
        nextMagIncr = numIncrs[closestIdx(nextMagIncr, numIncrs)];
    }
  } while (split <= scaleMax);
  return splits;
}
function asinhAxisSplits(self, axisIdx, scaleMin, scaleMax, foundIncr, foundSpace, forceMin) {
  let sc = self.scales[self.axes[axisIdx].scale];
  let linthresh = sc.asinh;
  let posSplits = scaleMax > linthresh ? logAxisSplits(self, axisIdx, max2(linthresh, scaleMin), scaleMax, foundIncr) : [linthresh];
  let zero = scaleMax >= 0 && scaleMin <= 0 ? [0] : [];
  let negSplits = scaleMin < -linthresh ? logAxisSplits(self, axisIdx, max2(linthresh, -scaleMax), -scaleMin, foundIncr) : [linthresh];
  return negSplits.reverse().map((v) => -v).concat(zero, posSplits);
}
var RE_ALL = /./;
var RE_12357 = /[12357]/;
var RE_125 = /[125]/;
var RE_1 = /1/;
var _filt = (splits, distr, re, keepMod) => splits.map((v, i) => distr == 4 && v == 0 || i % keepMod == 0 && re.test(v.toExponential()[v < 0 ? 1 : 0]) ? v : null);
function log10AxisValsFilt(self, splits, axisIdx, foundSpace, foundIncr) {
  let axis = self.axes[axisIdx];
  let scaleKey = axis.scale;
  let sc = self.scales[scaleKey];
  let valToPos = self.valToPos;
  let minSpace = axis._space;
  let _10 = valToPos(10, scaleKey);
  let re = valToPos(9, scaleKey) - _10 >= minSpace ? RE_ALL : valToPos(7, scaleKey) - _10 >= minSpace ? RE_12357 : valToPos(5, scaleKey) - _10 >= minSpace ? RE_125 : RE_1;
  if (re == RE_1) {
    let magSpace = abs(valToPos(1, scaleKey) - _10);
    if (magSpace < minSpace)
      return _filt(splits.slice().reverse(), sc.distr, re, ceil(minSpace / magSpace)).reverse();
  }
  return _filt(splits, sc.distr, re, 1);
}
function log2AxisValsFilt(self, splits, axisIdx, foundSpace, foundIncr) {
  let axis = self.axes[axisIdx];
  let scaleKey = axis.scale;
  let minSpace = axis._space;
  let valToPos = self.valToPos;
  let magSpace = abs(valToPos(1, scaleKey) - valToPos(2, scaleKey));
  if (magSpace < minSpace)
    return _filt(splits.slice().reverse(), 3, RE_ALL, ceil(minSpace / magSpace)).reverse();
  return splits;
}
function numSeriesVal(self, val, seriesIdx, dataIdx) {
  return dataIdx == null ? LEGEND_DISP : val == null ? "" : fmtNum(val);
}
var yAxisOpts = {
  show: true,
  scale: "y",
  stroke: hexBlack,
  space: 30,
  gap: 5,
  alignTo: 1,
  size: 50,
  labelGap: 0,
  labelSize: 30,
  labelFont,
  side: 3,
  //	class: "y-vals",
  //	incrs: numIncrs,
  //	values: (vals, space) => vals,
  //	filter: retArg1,
  grid,
  ticks,
  border,
  font,
  lineGap,
  rotate: 0
};
function ptDia(width, mult) {
  let dia = 3 + (width || 1) * 2;
  return roundDec(dia * mult, 3);
}
function seriesPointsShow(self, si) {
  let { scale, idxs } = self.series[0];
  let xData = self._data[0];
  let p0 = self.valToPos(xData[idxs[0]], scale, true);
  let p1 = self.valToPos(xData[idxs[1]], scale, true);
  let dim = abs(p1 - p0);
  let s = self.series[si];
  let maxPts = dim / (s.points.space * pxRatio);
  return idxs[1] - idxs[0] <= maxPts;
}
var facet = {
  scale: null,
  auto: true,
  sorted: 0,
  // internal caches
  min: inf,
  max: -inf
};
var gaps = (self, seriesIdx, idx0, idx1, nullGaps) => nullGaps;
var xySeriesOpts = {
  show: true,
  auto: true,
  sorted: 0,
  gaps,
  alpha: 1,
  facets: [
    assign({}, facet, { scale: "x" }),
    assign({}, facet, { scale: "y" })
  ]
};
var ySeriesOpts = {
  scale: "y",
  auto: true,
  sorted: 0,
  show: true,
  spanGaps: false,
  gaps,
  alpha: 1,
  points: {
    show: seriesPointsShow,
    filter: null
    //  paths:
    //	stroke: "#000",
    //	fill: "#fff",
    //	width: 1,
    //	size: 10,
  },
  //	label: "Value",
  //	value: v => v,
  values: null,
  // internal caches
  min: inf,
  max: -inf,
  idxs: [],
  path: null,
  clip: null
};
function clampScale(self, val, scaleMin, scaleMax, scaleKey) {
  return scaleMin / 10;
}
var xScaleOpts = {
  time: FEAT_TIME,
  auto: true,
  distr: 1,
  log: 10,
  asinh: 1,
  min: null,
  max: null,
  dir: 1,
  ori: 0
};
var yScaleOpts = assign({}, xScaleOpts, {
  time: false,
  ori: 1
});
var syncs = {};
function _sync(key, opts) {
  let s = syncs[key];
  if (!s) {
    s = {
      key,
      plots: [],
      sub(plot) {
        s.plots.push(plot);
      },
      unsub(plot) {
        s.plots = s.plots.filter((c) => c != plot);
      },
      pub(type, self, x, y, w, h, i) {
        for (let j = 0; j < s.plots.length; j++)
          s.plots[j] != self && s.plots[j].pub(type, self, x, y, w, h, i);
      }
    };
    if (key != null)
      syncs[key] = s;
  }
  return s;
}
var BAND_CLIP_FILL = 1 << 0;
var BAND_CLIP_STROKE = 1 << 1;
function orient(u, seriesIdx, cb) {
  const mode = u.mode;
  const series = u.series[seriesIdx];
  const data = mode == 2 ? u._data[seriesIdx] : u._data;
  const scales = u.scales;
  const bbox = u.bbox;
  let dx = data[0], dy = mode == 2 ? data[1] : data[seriesIdx], sx = mode == 2 ? scales[series.facets[0].scale] : scales[u.series[0].scale], sy = mode == 2 ? scales[series.facets[1].scale] : scales[series.scale], l = bbox.left, t = bbox.top, w = bbox.width, h = bbox.height, H = u.valToPosH, V = u.valToPosV;
  return sx.ori == 0 ? cb(
    series,
    dx,
    dy,
    sx,
    sy,
    H,
    V,
    l,
    t,
    w,
    h,
    moveToH,
    lineToH,
    rectH,
    arcH,
    bezierCurveToH
  ) : cb(
    series,
    dx,
    dy,
    sx,
    sy,
    V,
    H,
    t,
    l,
    h,
    w,
    moveToV,
    lineToV,
    rectV,
    arcV,
    bezierCurveToV
  );
}
function bandFillClipDirs(self, seriesIdx) {
  let fillDir = 0;
  let clipDirs = 0;
  let bands = ifNull(self.bands, EMPTY_ARR);
  for (let i = 0; i < bands.length; i++) {
    let b = bands[i];
    if (b.series[0] == seriesIdx)
      fillDir = b.dir;
    else if (b.series[1] == seriesIdx) {
      if (b.dir == 1)
        clipDirs |= 1;
      else
        clipDirs |= 2;
    }
  }
  return [
    fillDir,
    clipDirs == 1 ? -1 : (
      // neg only
      clipDirs == 2 ? 1 : (
        // pos only
        clipDirs == 3 ? 2 : (
          // both
          0
        )
      )
    )
  ];
}
function seriesFillTo(self, seriesIdx, dataMin, dataMax, bandFillDir) {
  let mode = self.mode;
  let series = self.series[seriesIdx];
  let scaleKey = mode == 2 ? series.facets[1].scale : series.scale;
  let scale = self.scales[scaleKey];
  return bandFillDir == -1 ? scale.min : bandFillDir == 1 ? scale.max : scale.distr == 3 ? scale.dir == 1 ? scale.min : scale.max : 0;
}
function clipBandLine(self, seriesIdx, idx0, idx1, strokePath, clipDir) {
  return orient(self, seriesIdx, (series, dataX, dataY, scaleX, scaleY, valToPosX, valToPosY, xOff, yOff, xDim, yDim) => {
    let pxRound = series.pxRound;
    const dir = scaleX.dir * (scaleX.ori == 0 ? 1 : -1);
    const lineTo = scaleX.ori == 0 ? lineToH : lineToV;
    let frIdx, toIdx;
    if (dir == 1) {
      frIdx = idx0;
      toIdx = idx1;
    } else {
      frIdx = idx1;
      toIdx = idx0;
    }
    let x0 = pxRound(valToPosX(dataX[frIdx], scaleX, xDim, xOff));
    let y0 = pxRound(valToPosY(dataY[frIdx], scaleY, yDim, yOff));
    let x1 = pxRound(valToPosX(dataX[toIdx], scaleX, xDim, xOff));
    let yLimit = pxRound(valToPosY(clipDir == 1 ? scaleY.max : scaleY.min, scaleY, yDim, yOff));
    let clip = new Path2D(strokePath);
    lineTo(clip, x1, yLimit);
    lineTo(clip, x0, yLimit);
    lineTo(clip, x0, y0);
    return clip;
  });
}
function clipGaps(gaps2, ori, plotLft, plotTop, plotWid, plotHgt) {
  let clip = null;
  if (gaps2.length > 0) {
    clip = new Path2D();
    const rect2 = ori == 0 ? rectH : rectV;
    let prevGapEnd = plotLft;
    for (let i = 0; i < gaps2.length; i++) {
      let g = gaps2[i];
      if (g[1] > g[0]) {
        let w2 = g[0] - prevGapEnd;
        w2 > 0 && rect2(clip, prevGapEnd, plotTop, w2, plotTop + plotHgt);
        prevGapEnd = g[1];
      }
    }
    let w = plotLft + plotWid - prevGapEnd;
    let maxStrokeWidth = 10;
    w > 0 && rect2(clip, prevGapEnd, plotTop - maxStrokeWidth / 2, w, plotTop + plotHgt + maxStrokeWidth);
  }
  return clip;
}
function addGap(gaps2, fromX, toX) {
  let prevGap = gaps2[gaps2.length - 1];
  if (prevGap && prevGap[0] == fromX)
    prevGap[1] = toX;
  else
    gaps2.push([fromX, toX]);
}
function findGaps(xs, ys, idx0, idx1, dir, pixelForX, align) {
  let gaps2 = [];
  let len = xs.length;
  for (let i = dir == 1 ? idx0 : idx1; i >= idx0 && i <= idx1; i += dir) {
    let yVal = ys[i];
    if (yVal === null) {
      let fr = i, to = i;
      if (dir == 1) {
        while (++i <= idx1 && ys[i] === null)
          to = i;
      } else {
        while (--i >= idx0 && ys[i] === null)
          to = i;
      }
      let frPx = pixelForX(xs[fr]);
      let toPx = to == fr ? frPx : pixelForX(xs[to]);
      let fri2 = fr - dir;
      let frPx2 = align <= 0 && fri2 >= 0 && fri2 < len ? pixelForX(xs[fri2]) : frPx;
      frPx = frPx2;
      let toi2 = to + dir;
      let toPx2 = align >= 0 && toi2 >= 0 && toi2 < len ? pixelForX(xs[toi2]) : toPx;
      toPx = toPx2;
      if (toPx >= frPx)
        gaps2.push([frPx, toPx]);
    }
  }
  return gaps2;
}
function pxRoundGen(pxAlign) {
  return pxAlign == 0 ? retArg0 : pxAlign == 1 ? round2 : (v) => incrRound(v, pxAlign);
}
function rect(ori) {
  let moveTo = ori == 0 ? moveToH : moveToV;
  let arcTo = ori == 0 ? (p, x1, y1, x2, y2, r) => {
    p.arcTo(x1, y1, x2, y2, r);
  } : (p, y1, x1, y2, x2, r) => {
    p.arcTo(x1, y1, x2, y2, r);
  };
  let rect2 = ori == 0 ? (p, x, y, w, h) => {
    p.rect(x, y, w, h);
  } : (p, y, x, h, w) => {
    p.rect(x, y, w, h);
  };
  return (p, x, y, w, h, endRad = 0, baseRad = 0) => {
    if (endRad == 0 && baseRad == 0)
      rect2(p, x, y, w, h);
    else {
      endRad = min2(endRad, w / 2, h / 2);
      baseRad = min2(baseRad, w / 2, h / 2);
      moveTo(p, x + endRad, y);
      arcTo(p, x + w, y, x + w, y + h, endRad);
      arcTo(p, x + w, y + h, x, y + h, baseRad);
      arcTo(p, x, y + h, x, y, baseRad);
      arcTo(p, x, y, x + w, y, endRad);
      p.closePath();
    }
  };
}
var moveToH = (p, x, y) => {
  p.moveTo(x, y);
};
var moveToV = (p, y, x) => {
  p.moveTo(x, y);
};
var lineToH = (p, x, y) => {
  p.lineTo(x, y);
};
var lineToV = (p, y, x) => {
  p.lineTo(x, y);
};
var rectH = rect(0);
var rectV = rect(1);
var arcH = (p, x, y, r, startAngle, endAngle) => {
  p.arc(x, y, r, startAngle, endAngle);
};
var arcV = (p, y, x, r, startAngle, endAngle) => {
  p.arc(x, y, r, startAngle, endAngle);
};
var bezierCurveToH = (p, bp1x, bp1y, bp2x, bp2y, p2x, p2y) => {
  p.bezierCurveTo(bp1x, bp1y, bp2x, bp2y, p2x, p2y);
};
var bezierCurveToV = (p, bp1y, bp1x, bp2y, bp2x, p2y, p2x) => {
  p.bezierCurveTo(bp1x, bp1y, bp2x, bp2y, p2x, p2y);
};
function points(opts) {
  return (u, seriesIdx, idx0, idx1, filtIdxs) => {
    return orient(u, seriesIdx, (series, dataX, dataY, scaleX, scaleY, valToPosX, valToPosY, xOff, yOff, xDim, yDim) => {
      let { pxRound, points: points2 } = series;
      let moveTo, arc;
      if (scaleX.ori == 0) {
        moveTo = moveToH;
        arc = arcH;
      } else {
        moveTo = moveToV;
        arc = arcV;
      }
      const width = roundDec(points2.width * pxRatio, 3);
      let rad = (points2.size - points2.width) / 2 * pxRatio;
      let dia = roundDec(rad * 2, 3);
      let fill = new Path2D();
      let clip = new Path2D();
      let { left: lft, top, width: wid, height: hgt } = u.bbox;
      rectH(
        clip,
        lft - dia,
        top - dia,
        wid + dia * 2,
        hgt + dia * 2
      );
      const drawPoint = (pi) => {
        if (dataY[pi] != null) {
          let x = pxRound(valToPosX(dataX[pi], scaleX, xDim, xOff));
          let y = pxRound(valToPosY(dataY[pi], scaleY, yDim, yOff));
          moveTo(fill, x + rad, y);
          arc(fill, x, y, rad, 0, PI * 2);
        }
      };
      if (filtIdxs)
        filtIdxs.forEach(drawPoint);
      else {
        for (let pi = idx0; pi <= idx1; pi++)
          drawPoint(pi);
      }
      return {
        stroke: width > 0 ? fill : null,
        fill,
        clip,
        flags: BAND_CLIP_FILL | BAND_CLIP_STROKE
      };
    });
  };
}
function _drawAcc(lineTo) {
  return (stroke, accX, minY, maxY, inY, outY) => {
    if (minY != maxY) {
      if (inY != minY && outY != minY)
        lineTo(stroke, accX, minY);
      if (inY != maxY && outY != maxY)
        lineTo(stroke, accX, maxY);
      lineTo(stroke, accX, outY);
    }
  };
}
var drawAccH = _drawAcc(lineToH);
var drawAccV = _drawAcc(lineToV);
function linear(opts) {
  const alignGaps = ifNull(opts?.alignGaps, 0);
  return (u, seriesIdx, idx0, idx1) => {
    return orient(u, seriesIdx, (series, dataX, dataY, scaleX, scaleY, valToPosX, valToPosY, xOff, yOff, xDim, yDim) => {
      [idx0, idx1] = nonNullIdxs(dataY, idx0, idx1);
      let pxRound = series.pxRound;
      let pixelForX = (val) => pxRound(valToPosX(val, scaleX, xDim, xOff));
      let pixelForY = (val) => pxRound(valToPosY(val, scaleY, yDim, yOff));
      let lineTo, drawAcc;
      if (scaleX.ori == 0) {
        lineTo = lineToH;
        drawAcc = drawAccH;
      } else {
        lineTo = lineToV;
        drawAcc = drawAccV;
      }
      const dir = scaleX.dir * (scaleX.ori == 0 ? 1 : -1);
      const _paths = { stroke: new Path2D(), fill: null, clip: null, band: null, gaps: null, flags: BAND_CLIP_FILL };
      const stroke = _paths.stroke;
      let hasGap = false;
      const decimate = idx1 - idx0 >= xDim * 4;
      if (decimate) {
        let xForPixel = (pos) => u.posToVal(pos, scaleX.key, true);
        let minY = null, maxY = null, inY, outY, drawnAtX;
        let accX = pixelForX(dataX[dir == 1 ? idx0 : idx1]);
        let idx0px = pixelForX(dataX[idx0]);
        let idx1px = pixelForX(dataX[idx1]);
        let nextAccXVal = xForPixel(dir == 1 ? idx0px + 1 : idx1px - 1);
        for (let i = dir == 1 ? idx0 : idx1; i >= idx0 && i <= idx1; i += dir) {
          let xVal = dataX[i];
          let reuseAccX = dir == 1 ? xVal < nextAccXVal : xVal > nextAccXVal;
          let x = reuseAccX ? accX : pixelForX(xVal);
          let yVal = dataY[i];
          if (x == accX) {
            if (yVal != null) {
              outY = yVal;
              if (minY == null) {
                lineTo(stroke, x, pixelForY(outY));
                inY = minY = maxY = outY;
              } else {
                if (outY < minY)
                  minY = outY;
                else if (outY > maxY)
                  maxY = outY;
              }
            } else {
              if (yVal === null)
                hasGap = true;
            }
          } else {
            if (minY != null)
              drawAcc(stroke, accX, pixelForY(minY), pixelForY(maxY), pixelForY(inY), pixelForY(outY));
            if (yVal != null) {
              outY = yVal;
              lineTo(stroke, x, pixelForY(outY));
              minY = maxY = inY = outY;
            } else {
              minY = maxY = null;
              if (yVal === null)
                hasGap = true;
            }
            accX = x;
            nextAccXVal = xForPixel(accX + dir);
          }
        }
        if (minY != null && minY != maxY && drawnAtX != accX)
          drawAcc(stroke, accX, pixelForY(minY), pixelForY(maxY), pixelForY(inY), pixelForY(outY));
      } else {
        for (let i = dir == 1 ? idx0 : idx1; i >= idx0 && i <= idx1; i += dir) {
          let yVal = dataY[i];
          if (yVal === null)
            hasGap = true;
          else if (yVal != null)
            lineTo(stroke, pixelForX(dataX[i]), pixelForY(yVal));
        }
      }
      let [bandFillDir, bandClipDir] = bandFillClipDirs(u, seriesIdx);
      if (series.fill != null || bandFillDir != 0) {
        let fill = _paths.fill = new Path2D(stroke);
        let fillToVal = series.fillTo(u, seriesIdx, series.min, series.max, bandFillDir);
        let fillToY = pixelForY(fillToVal);
        let frX = pixelForX(dataX[idx0]);
        let toX = pixelForX(dataX[idx1]);
        if (dir == -1)
          [toX, frX] = [frX, toX];
        lineTo(fill, toX, fillToY);
        lineTo(fill, frX, fillToY);
      }
      if (!series.spanGaps) {
        let gaps2 = [];
        hasGap && gaps2.push(...findGaps(dataX, dataY, idx0, idx1, dir, pixelForX, alignGaps));
        _paths.gaps = gaps2 = series.gaps(u, seriesIdx, idx0, idx1, gaps2);
        _paths.clip = clipGaps(gaps2, scaleX.ori, xOff, yOff, xDim, yDim);
      }
      if (bandClipDir != 0) {
        _paths.band = bandClipDir == 2 ? [
          clipBandLine(u, seriesIdx, idx0, idx1, stroke, -1),
          clipBandLine(u, seriesIdx, idx0, idx1, stroke, 1)
        ] : clipBandLine(u, seriesIdx, idx0, idx1, stroke, bandClipDir);
      }
      return _paths;
    });
  };
}
function stepped(opts) {
  const align = ifNull(opts.align, 1);
  const ascDesc = ifNull(opts.ascDesc, false);
  const alignGaps = ifNull(opts.alignGaps, 0);
  const extend = ifNull(opts.extend, false);
  return (u, seriesIdx, idx0, idx1) => {
    return orient(u, seriesIdx, (series, dataX, dataY, scaleX, scaleY, valToPosX, valToPosY, xOff, yOff, xDim, yDim) => {
      [idx0, idx1] = nonNullIdxs(dataY, idx0, idx1);
      let pxRound = series.pxRound;
      let { left, width } = u.bbox;
      let pixelForX = (val) => pxRound(valToPosX(val, scaleX, xDim, xOff));
      let pixelForY = (val) => pxRound(valToPosY(val, scaleY, yDim, yOff));
      let lineTo = scaleX.ori == 0 ? lineToH : lineToV;
      const _paths = { stroke: new Path2D(), fill: null, clip: null, band: null, gaps: null, flags: BAND_CLIP_FILL };
      const stroke = _paths.stroke;
      const dir = scaleX.dir * (scaleX.ori == 0 ? 1 : -1);
      let prevYPos = pixelForY(dataY[dir == 1 ? idx0 : idx1]);
      let firstXPos = pixelForX(dataX[dir == 1 ? idx0 : idx1]);
      let prevXPos = firstXPos;
      let firstXPosExt = firstXPos;
      if (extend && align == -1) {
        firstXPosExt = left;
        lineTo(stroke, firstXPosExt, prevYPos);
      }
      lineTo(stroke, firstXPos, prevYPos);
      for (let i = dir == 1 ? idx0 : idx1; i >= idx0 && i <= idx1; i += dir) {
        let yVal1 = dataY[i];
        if (yVal1 == null)
          continue;
        let x1 = pixelForX(dataX[i]);
        let y1 = pixelForY(yVal1);
        if (align == 1)
          lineTo(stroke, x1, prevYPos);
        else
          lineTo(stroke, prevXPos, y1);
        lineTo(stroke, x1, y1);
        prevYPos = y1;
        prevXPos = x1;
      }
      let prevXPosExt = prevXPos;
      if (extend && align == 1) {
        prevXPosExt = left + width;
        lineTo(stroke, prevXPosExt, prevYPos);
      }
      let [bandFillDir, bandClipDir] = bandFillClipDirs(u, seriesIdx);
      if (series.fill != null || bandFillDir != 0) {
        let fill = _paths.fill = new Path2D(stroke);
        let fillTo = series.fillTo(u, seriesIdx, series.min, series.max, bandFillDir);
        let fillToY = pixelForY(fillTo);
        lineTo(fill, prevXPosExt, fillToY);
        lineTo(fill, firstXPosExt, fillToY);
      }
      if (!series.spanGaps) {
        let gaps2 = [];
        gaps2.push(...findGaps(dataX, dataY, idx0, idx1, dir, pixelForX, alignGaps));
        let halfStroke = series.width * pxRatio / 2;
        let startsOffset = ascDesc || align == 1 ? halfStroke : -halfStroke;
        let endsOffset = ascDesc || align == -1 ? -halfStroke : halfStroke;
        gaps2.forEach((g) => {
          g[0] += startsOffset;
          g[1] += endsOffset;
        });
        _paths.gaps = gaps2 = series.gaps(u, seriesIdx, idx0, idx1, gaps2);
        _paths.clip = clipGaps(gaps2, scaleX.ori, xOff, yOff, xDim, yDim);
      }
      if (bandClipDir != 0) {
        _paths.band = bandClipDir == 2 ? [
          clipBandLine(u, seriesIdx, idx0, idx1, stroke, -1),
          clipBandLine(u, seriesIdx, idx0, idx1, stroke, 1)
        ] : clipBandLine(u, seriesIdx, idx0, idx1, stroke, bandClipDir);
      }
      return _paths;
    });
  };
}
function findColWidth(dataX, dataY, valToPosX, scaleX, xDim, xOff, colWid = inf) {
  if (dataX.length > 1) {
    let prevIdx = null;
    for (let i = 0, minDelta = Infinity; i < dataX.length; i++) {
      if (dataY[i] !== void 0) {
        if (prevIdx != null) {
          let delta = abs(dataX[i] - dataX[prevIdx]);
          if (delta < minDelta) {
            minDelta = delta;
            colWid = abs(valToPosX(dataX[i], scaleX, xDim, xOff) - valToPosX(dataX[prevIdx], scaleX, xDim, xOff));
          }
        }
        prevIdx = i;
      }
    }
  }
  return colWid;
}
function bars(opts) {
  opts = opts || EMPTY_OBJ;
  const size3 = ifNull(opts.size, [0.6, inf, 1]);
  const align = opts.align || 0;
  const _extraGap = opts.gap || 0;
  let ro = opts.radius;
  ro = // [valueRadius, baselineRadius]
  ro == null ? [0, 0] : typeof ro == "number" ? [ro, 0] : ro;
  const radiusFn = fnOrSelf(ro);
  const gapFactor = 1 - size3[0];
  const _maxWidth = ifNull(size3[1], inf);
  const _minWidth = ifNull(size3[2], 1);
  const disp = ifNull(opts.disp, EMPTY_OBJ);
  const _each = ifNull(opts.each, (_2) => {
  });
  const { fill: dispFills, stroke: dispStrokes } = disp;
  return (u, seriesIdx, idx0, idx1) => {
    return orient(u, seriesIdx, (series, dataX, dataY, scaleX, scaleY, valToPosX, valToPosY, xOff, yOff, xDim, yDim) => {
      let pxRound = series.pxRound;
      let _align = align;
      let extraGap = _extraGap * pxRatio;
      let maxWidth = _maxWidth * pxRatio;
      let minWidth = _minWidth * pxRatio;
      let valRadius, baseRadius;
      if (scaleX.ori == 0)
        [valRadius, baseRadius] = radiusFn(u, seriesIdx);
      else
        [baseRadius, valRadius] = radiusFn(u, seriesIdx);
      const _dirX = scaleX.dir * (scaleX.ori == 0 ? 1 : -1);
      let rect2 = scaleX.ori == 0 ? rectH : rectV;
      let each = scaleX.ori == 0 ? _each : (u2, seriesIdx2, i, top, lft, hgt, wid) => {
        _each(u2, seriesIdx2, i, lft, top, wid, hgt);
      };
      let band = ifNull(u.bands, EMPTY_ARR).find((b) => b.series[0] == seriesIdx);
      let fillDir = band != null ? band.dir : 0;
      let fillTo = series.fillTo(u, seriesIdx, series.min, series.max, fillDir);
      let fillToY = pxRound(valToPosY(fillTo, scaleY, yDim, yOff));
      let xShift, barWid, fullGap, colWid = xDim;
      let strokeWidth = pxRound(series.width * pxRatio);
      let multiPath = false;
      let fillColors = null;
      let fillPaths = null;
      let strokeColors = null;
      let strokePaths = null;
      if (dispFills != null && (strokeWidth == 0 || dispStrokes != null)) {
        multiPath = true;
        fillColors = dispFills.values(u, seriesIdx, idx0, idx1);
        fillPaths = /* @__PURE__ */ new Map();
        new Set(fillColors).forEach((color) => {
          if (color != null)
            fillPaths.set(color, new Path2D());
        });
        if (strokeWidth > 0) {
          strokeColors = dispStrokes.values(u, seriesIdx, idx0, idx1);
          strokePaths = /* @__PURE__ */ new Map();
          new Set(strokeColors).forEach((color) => {
            if (color != null)
              strokePaths.set(color, new Path2D());
          });
        }
      }
      let { x0, size: size4 } = disp;
      if (x0 != null && size4 != null) {
        _align = 1;
        dataX = x0.values(u, seriesIdx, idx0, idx1);
        if (x0.unit == 2)
          dataX = dataX.map((pct) => u.posToVal(xOff + pct * xDim, scaleX.key, true));
        let sizes = size4.values(u, seriesIdx, idx0, idx1);
        if (size4.unit == 2)
          barWid = sizes[0] * xDim;
        else
          barWid = valToPosX(sizes[0], scaleX, xDim, xOff) - valToPosX(0, scaleX, xDim, xOff);
        colWid = findColWidth(dataX, dataY, valToPosX, scaleX, xDim, xOff, colWid);
        let gapWid = colWid - barWid;
        fullGap = gapWid + extraGap;
      } else {
        colWid = findColWidth(dataX, dataY, valToPosX, scaleX, xDim, xOff, colWid);
        let gapWid = colWid * gapFactor;
        fullGap = gapWid + extraGap;
        barWid = colWid - fullGap;
      }
      if (fullGap < 1)
        fullGap = 0;
      if (strokeWidth >= barWid / 2)
        strokeWidth = 0;
      if (fullGap < 5)
        pxRound = retArg0;
      let insetStroke = fullGap > 0;
      let rawBarWid = colWid - fullGap - (insetStroke ? strokeWidth : 0);
      barWid = pxRound(clamp2(rawBarWid, minWidth, maxWidth));
      xShift = (_align == 0 ? barWid / 2 : _align == _dirX ? 0 : barWid) - _align * _dirX * ((_align == 0 ? extraGap / 2 : 0) + (insetStroke ? strokeWidth / 2 : 0));
      const _paths = { stroke: null, fill: null, clip: null, band: null, gaps: null, flags: 0 };
      const stroke = multiPath ? null : new Path2D();
      let dataY0 = null;
      if (band != null)
        dataY0 = u.data[band.series[1]];
      else {
        let { y0, y1 } = disp;
        if (y0 != null && y1 != null) {
          dataY = y1.values(u, seriesIdx, idx0, idx1);
          dataY0 = y0.values(u, seriesIdx, idx0, idx1);
        }
      }
      let radVal = valRadius * barWid;
      let radBase = baseRadius * barWid;
      for (let i = _dirX == 1 ? idx0 : idx1; i >= idx0 && i <= idx1; i += _dirX) {
        let yVal = dataY[i];
        if (yVal == null)
          continue;
        if (dataY0 != null) {
          let yVal0 = dataY0[i] ?? 0;
          if (yVal - yVal0 == 0)
            continue;
          fillToY = valToPosY(yVal0, scaleY, yDim, yOff);
        }
        let xVal = scaleX.distr != 2 || disp != null ? dataX[i] : i;
        let xPos = valToPosX(xVal, scaleX, xDim, xOff);
        let yPos = valToPosY(ifNull(yVal, fillTo), scaleY, yDim, yOff);
        let lft = pxRound(xPos - xShift);
        let btm = pxRound(max2(yPos, fillToY));
        let top = pxRound(min2(yPos, fillToY));
        let barHgt = btm - top;
        if (yVal != null) {
          let rv = yVal < 0 ? radBase : radVal;
          let rb = yVal < 0 ? radVal : radBase;
          if (multiPath) {
            if (strokeWidth > 0 && strokeColors[i] != null)
              rect2(strokePaths.get(strokeColors[i]), lft, top + floor2(strokeWidth / 2), barWid, max2(0, barHgt - strokeWidth), rv, rb);
            if (fillColors[i] != null)
              rect2(fillPaths.get(fillColors[i]), lft, top + floor2(strokeWidth / 2), barWid, max2(0, barHgt - strokeWidth), rv, rb);
          } else
            rect2(stroke, lft, top + floor2(strokeWidth / 2), barWid, max2(0, barHgt - strokeWidth), rv, rb);
          each(
            u,
            seriesIdx,
            i,
            lft - strokeWidth / 2,
            top,
            barWid + strokeWidth,
            barHgt
          );
        }
      }
      if (strokeWidth > 0)
        _paths.stroke = multiPath ? strokePaths : stroke;
      else if (!multiPath) {
        _paths._fill = series.width == 0 ? series._fill : series._stroke ?? series._fill;
        _paths.width = 0;
      }
      _paths.fill = multiPath ? fillPaths : stroke;
      return _paths;
    });
  };
}
function splineInterp(interp, opts) {
  const alignGaps = ifNull(opts?.alignGaps, 0);
  return (u, seriesIdx, idx0, idx1) => {
    return orient(u, seriesIdx, (series, dataX, dataY, scaleX, scaleY, valToPosX, valToPosY, xOff, yOff, xDim, yDim) => {
      [idx0, idx1] = nonNullIdxs(dataY, idx0, idx1);
      let pxRound = series.pxRound;
      let pixelForX = (val) => pxRound(valToPosX(val, scaleX, xDim, xOff));
      let pixelForY = (val) => pxRound(valToPosY(val, scaleY, yDim, yOff));
      let moveTo, bezierCurveTo, lineTo;
      if (scaleX.ori == 0) {
        moveTo = moveToH;
        lineTo = lineToH;
        bezierCurveTo = bezierCurveToH;
      } else {
        moveTo = moveToV;
        lineTo = lineToV;
        bezierCurveTo = bezierCurveToV;
      }
      const dir = scaleX.dir * (scaleX.ori == 0 ? 1 : -1);
      let firstXPos = pixelForX(dataX[dir == 1 ? idx0 : idx1]);
      let prevXPos = firstXPos;
      let xCoords = [];
      let yCoords = [];
      for (let i = dir == 1 ? idx0 : idx1; i >= idx0 && i <= idx1; i += dir) {
        let yVal = dataY[i];
        if (yVal != null) {
          let xVal = dataX[i];
          let xPos = pixelForX(xVal);
          xCoords.push(prevXPos = xPos);
          yCoords.push(pixelForY(dataY[i]));
        }
      }
      const _paths = { stroke: interp(xCoords, yCoords, moveTo, lineTo, bezierCurveTo, pxRound), fill: null, clip: null, band: null, gaps: null, flags: BAND_CLIP_FILL };
      const stroke = _paths.stroke;
      let [bandFillDir, bandClipDir] = bandFillClipDirs(u, seriesIdx);
      if (series.fill != null || bandFillDir != 0) {
        let fill = _paths.fill = new Path2D(stroke);
        let fillTo = series.fillTo(u, seriesIdx, series.min, series.max, bandFillDir);
        let fillToY = pixelForY(fillTo);
        lineTo(fill, prevXPos, fillToY);
        lineTo(fill, firstXPos, fillToY);
      }
      if (!series.spanGaps) {
        let gaps2 = [];
        gaps2.push(...findGaps(dataX, dataY, idx0, idx1, dir, pixelForX, alignGaps));
        _paths.gaps = gaps2 = series.gaps(u, seriesIdx, idx0, idx1, gaps2);
        _paths.clip = clipGaps(gaps2, scaleX.ori, xOff, yOff, xDim, yDim);
      }
      if (bandClipDir != 0) {
        _paths.band = bandClipDir == 2 ? [
          clipBandLine(u, seriesIdx, idx0, idx1, stroke, -1),
          clipBandLine(u, seriesIdx, idx0, idx1, stroke, 1)
        ] : clipBandLine(u, seriesIdx, idx0, idx1, stroke, bandClipDir);
      }
      return _paths;
    });
  };
}
function monotoneCubic(opts) {
  return splineInterp(_monotoneCubic, opts);
}
function _monotoneCubic(xs, ys, moveTo, lineTo, bezierCurveTo, pxRound) {
  const n = xs.length;
  if (n < 2)
    return null;
  const path = new Path2D();
  moveTo(path, xs[0], ys[0]);
  if (n == 2)
    lineTo(path, xs[1], ys[1]);
  else {
    let ms = Array(n), ds = Array(n - 1), dys = Array(n - 1), dxs = Array(n - 1);
    for (let i = 0; i < n - 1; i++) {
      dys[i] = ys[i + 1] - ys[i];
      dxs[i] = xs[i + 1] - xs[i];
      ds[i] = dys[i] / dxs[i];
    }
    ms[0] = ds[0];
    for (let i = 1; i < n - 1; i++) {
      if (ds[i] === 0 || ds[i - 1] === 0 || ds[i - 1] > 0 !== ds[i] > 0)
        ms[i] = 0;
      else {
        ms[i] = 3 * (dxs[i - 1] + dxs[i]) / ((2 * dxs[i] + dxs[i - 1]) / ds[i - 1] + (dxs[i] + 2 * dxs[i - 1]) / ds[i]);
        if (!isFinite(ms[i]))
          ms[i] = 0;
      }
    }
    ms[n - 1] = ds[n - 2];
    for (let i = 0; i < n - 1; i++) {
      bezierCurveTo(
        path,
        xs[i] + dxs[i] / 3,
        ys[i] + ms[i] * dxs[i] / 3,
        xs[i + 1] - dxs[i] / 3,
        ys[i + 1] - ms[i + 1] * dxs[i] / 3,
        xs[i + 1],
        ys[i + 1]
      );
    }
  }
  return path;
}
var cursorPlots = /* @__PURE__ */ new Set();
function invalidateRects() {
  for (let u of cursorPlots)
    u.syncRect(true);
}
if (domEnv) {
  on(resize, win, invalidateRects);
  on(scroll, win, invalidateRects, true);
  on(dppxchange, win, () => {
    uPlot.pxRatio = pxRatio;
  });
}
var linearPath = linear();
var pointsPath = points();
function setDefaults(d, xo, yo, initY) {
  let d2 = initY ? [d[0], d[1]].concat(d.slice(2)) : [d[0]].concat(d.slice(1));
  return d2.map((o, i) => setDefault(o, i, xo, yo));
}
function setDefaults2(d, xyo) {
  return d.map((o, i) => i == 0 ? {} : assign({}, xyo, o));
}
function setDefault(o, i, xo, yo) {
  return assign({}, i == 0 ? xo : yo, o);
}
function snapNumX(self, dataMin, dataMax) {
  return dataMin == null ? nullNullTuple : [dataMin, dataMax];
}
var snapTimeX = snapNumX;
function snapNumY(self, dataMin, dataMax) {
  return dataMin == null ? nullNullTuple : rangeNum(dataMin, dataMax, rangePad, true);
}
function snapLogY(self, dataMin, dataMax, scale) {
  return dataMin == null ? nullNullTuple : rangeLog(dataMin, dataMax, self.scales[scale].log, false);
}
var snapLogX = snapLogY;
function snapAsinhY(self, dataMin, dataMax, scale) {
  return dataMin == null ? nullNullTuple : rangeAsinh(dataMin, dataMax, self.scales[scale].log, false);
}
var snapAsinhX = snapAsinhY;
function findIncr(minVal, maxVal, incrs, dim, minSpace) {
  let intDigits = max2(numIntDigits(minVal), numIntDigits(maxVal));
  let delta = maxVal - minVal;
  let incrIdx = closestIdx(minSpace / dim * delta, incrs);
  do {
    let foundIncr = incrs[incrIdx];
    let foundSpace = dim * foundIncr / delta;
    if (foundSpace >= minSpace && intDigits + (foundIncr < 5 ? fixedDec.get(foundIncr) : 0) <= 17)
      return [foundIncr, foundSpace];
  } while (++incrIdx < incrs.length);
  return [0, 0];
}
function pxRatioFont(font2) {
  let fontSize, fontSizeCss;
  font2 = font2.replace(/(\d+)px/, (m, p1) => (fontSize = round2((fontSizeCss = +p1) * pxRatio)) + "px");
  return [font2, fontSize, fontSizeCss];
}
function syncFontSize(axis) {
  if (axis.show) {
    [axis.font, axis.labelFont].forEach((f) => {
      let size3 = roundDec(f[2] * pxRatio, 1);
      f[0] = f[0].replace(/[0-9.]+px/, size3 + "px");
      f[1] = size3;
    });
  }
}
function uPlot(opts, data, then) {
  const self = {
    mode: ifNull(opts.mode, 1)
  };
  const mode = self.mode;
  function getHPos(val, scale, dim, off2) {
    let pct = scale.valToPct(val);
    return off2 + dim * (scale.dir == -1 ? 1 - pct : pct);
  }
  function getVPos(val, scale, dim, off2) {
    let pct = scale.valToPct(val);
    return off2 + dim * (scale.dir == -1 ? pct : 1 - pct);
  }
  function getPos(val, scale, dim, off2) {
    return scale.ori == 0 ? getHPos(val, scale, dim, off2) : getVPos(val, scale, dim, off2);
  }
  self.valToPosH = getHPos;
  self.valToPosV = getVPos;
  let ready = false;
  self.status = 0;
  const root = self.root = placeDiv(UPLOT);
  if (opts.id != null)
    root.id = opts.id;
  addClass(root, opts.class);
  if (opts.title) {
    let title = placeDiv(TITLE, root);
    title.textContent = opts.title;
  }
  const can = placeTag("canvas");
  const ctx = self.ctx = can.getContext("2d");
  const wrap = placeDiv(WRAP, root);
  on("click", wrap, (e) => {
    if (e.target === over) {
      let didDrag = mouseLeft1 != mouseLeft0 || mouseTop1 != mouseTop0;
      didDrag && drag.click(self, e);
    }
  }, true);
  const under = self.under = placeDiv(UNDER, wrap);
  wrap.appendChild(can);
  const over = self.over = placeDiv(OVER, wrap);
  opts = copy(opts);
  const pxAlign = +ifNull(opts.pxAlign, 1);
  const pxRound = pxRoundGen(pxAlign);
  (opts.plugins || []).forEach((p) => {
    if (p.opts)
      opts = p.opts(self, opts) || opts;
  });
  const ms = opts.ms || 1e-3;
  const series = self.series = mode == 1 ? setDefaults(opts.series || [], xSeriesOpts, ySeriesOpts, false) : setDefaults2(opts.series || [null], xySeriesOpts);
  const axes = self.axes = setDefaults(opts.axes || [], xAxisOpts, yAxisOpts, true);
  const scales = self.scales = {};
  const bands = self.bands = opts.bands || [];
  bands.forEach((b) => {
    b.fill = fnOrSelf(b.fill || null);
    b.dir = ifNull(b.dir, -1);
  });
  const xScaleKey = mode == 2 ? series[1].facets[0].scale : series[0].scale;
  const drawOrderMap = {
    axes: drawAxesGrid,
    series: drawSeries
  };
  const drawOrder = (opts.drawOrder || ["axes", "series"]).map((key2) => drawOrderMap[key2]);
  function initValToPct(sc) {
    const getVal = sc.distr == 3 ? (val) => log10(val > 0 ? val : sc.clamp(self, val, sc.min, sc.max, sc.key)) : sc.distr == 4 ? (val) => asinh(val, sc.asinh) : sc.distr == 100 ? (val) => sc.fwd(val) : (val) => val;
    return (val) => {
      let _val = getVal(val);
      let { _min, _max } = sc;
      let delta = _max - _min;
      return (_val - _min) / delta;
    };
  }
  function initScale(scaleKey) {
    let sc = scales[scaleKey];
    if (sc == null) {
      let scaleOpts = (opts.scales || EMPTY_OBJ)[scaleKey] || EMPTY_OBJ;
      if (scaleOpts.from != null) {
        initScale(scaleOpts.from);
        let sc2 = assign({}, scales[scaleOpts.from], scaleOpts, { key: scaleKey });
        sc2.valToPct = initValToPct(sc2);
        scales[scaleKey] = sc2;
      } else {
        sc = scales[scaleKey] = assign({}, scaleKey == xScaleKey ? xScaleOpts : yScaleOpts, scaleOpts);
        sc.key = scaleKey;
        let isTime = sc.time;
        let rn = sc.range;
        let rangeIsArr = isArr(rn);
        if (scaleKey != xScaleKey || mode == 2 && !isTime) {
          if (rangeIsArr && (rn[0] == null || rn[1] == null)) {
            rn = {
              min: rn[0] == null ? autoRangePart : {
                mode: 1,
                hard: rn[0],
                soft: rn[0]
              },
              max: rn[1] == null ? autoRangePart : {
                mode: 1,
                hard: rn[1],
                soft: rn[1]
              }
            };
            rangeIsArr = false;
          }
          if (!rangeIsArr && isObj(rn)) {
            let cfg = rn;
            rn = (self2, dataMin, dataMax) => dataMin == null ? nullNullTuple : rangeNum(dataMin, dataMax, cfg);
          }
        }
        sc.range = fnOrSelf(rn || (isTime ? snapTimeX : scaleKey == xScaleKey ? sc.distr == 3 ? snapLogX : sc.distr == 4 ? snapAsinhX : snapNumX : sc.distr == 3 ? snapLogY : sc.distr == 4 ? snapAsinhY : snapNumY));
        sc.auto = fnOrSelf(rangeIsArr ? false : sc.auto);
        sc.clamp = fnOrSelf(sc.clamp || clampScale);
        sc._min = sc._max = null;
        sc.valToPct = initValToPct(sc);
      }
    }
  }
  initScale("x");
  initScale("y");
  if (mode == 1) {
    series.forEach((s) => {
      initScale(s.scale);
    });
  }
  axes.forEach((a) => {
    initScale(a.scale);
  });
  for (let k in opts.scales)
    initScale(k);
  const scaleX = scales[xScaleKey];
  const xScaleDistr = scaleX.distr;
  let valToPosX, valToPosY;
  if (scaleX.ori == 0) {
    addClass(root, ORI_HZ);
    valToPosX = getHPos;
    valToPosY = getVPos;
  } else {
    addClass(root, ORI_VT);
    valToPosX = getVPos;
    valToPosY = getHPos;
  }
  const pendScales = {};
  for (let k in scales) {
    let sc = scales[k];
    if (sc.min != null || sc.max != null) {
      pendScales[k] = { min: sc.min, max: sc.max };
      sc.min = sc.max = null;
    }
  }
  const _tzDate = opts.tzDate || ((ts) => new Date(round2(ts / ms)));
  const _fmtDate = opts.fmtDate || fmtDate;
  const _timeAxisSplits = ms == 1 ? timeAxisSplitsMs(_tzDate) : timeAxisSplitsS(_tzDate);
  const _timeAxisVals = timeAxisVals(_tzDate, timeAxisStamps(ms == 1 ? _timeAxisStampsMs : _timeAxisStampsS, _fmtDate));
  const _timeSeriesVal = timeSeriesVal(_tzDate, timeSeriesStamp(_timeSeriesStamp, _fmtDate));
  const activeIdxs = [];
  const legend = self.legend = assign({}, legendOpts, opts.legend);
  const cursor = self.cursor = assign({}, cursorOpts, { drag: { y: mode == 2 } }, opts.cursor);
  const showLegend = legend.show;
  const showCursor = cursor.show;
  const markers = legend.markers;
  {
    legend.idxs = activeIdxs;
    markers.width = fnOrSelf(markers.width);
    markers.dash = fnOrSelf(markers.dash);
    markers.stroke = fnOrSelf(markers.stroke);
    markers.fill = fnOrSelf(markers.fill);
  }
  let legendTable;
  let legendHead;
  let legendBody;
  let legendRows = [];
  let legendCells = [];
  let legendCols;
  let multiValLegend = false;
  let NULL_LEGEND_VALUES = {};
  if (legend.live) {
    const getMultiVals = series[1] ? series[1].values : null;
    multiValLegend = getMultiVals != null;
    legendCols = multiValLegend ? getMultiVals(self, 1, 0) : { _: 0 };
    for (let k in legendCols)
      NULL_LEGEND_VALUES[k] = LEGEND_DISP;
  }
  if (showLegend) {
    legendTable = placeTag("table", LEGEND, root);
    legendBody = placeTag("tbody", null, legendTable);
    legend.mount(self, legendTable);
    if (multiValLegend) {
      legendHead = placeTag("thead", null, legendTable, legendBody);
      let head = placeTag("tr", null, legendHead);
      placeTag("th", null, head);
      for (var key in legendCols)
        placeTag("th", LEGEND_LABEL, head).textContent = key;
    } else {
      addClass(legendTable, LEGEND_INLINE);
      legend.live && addClass(legendTable, LEGEND_LIVE);
    }
  }
  const son = { show: true };
  const soff = { show: false };
  function initLegendRow(s, i) {
    if (i == 0 && (multiValLegend || !legend.live || mode == 2))
      return nullNullTuple;
    let cells = [];
    let row = placeTag("tr", LEGEND_SERIES, legendBody, legendBody.childNodes[i]);
    addClass(row, s.class);
    if (!s.show)
      addClass(row, OFF);
    let label = placeTag("th", null, row);
    if (markers.show) {
      let indic = placeDiv(LEGEND_MARKER, label);
      if (i > 0) {
        let width = markers.width(self, i);
        if (width)
          indic.style.border = width + "px " + markers.dash(self, i) + " " + markers.stroke(self, i);
        indic.style.background = markers.fill(self, i);
      }
    }
    let text = placeDiv(LEGEND_LABEL, label);
    if (s.label instanceof HTMLElement)
      text.appendChild(s.label);
    else
      text.textContent = s.label;
    if (i > 0) {
      if (!markers.show)
        text.style.color = s.width > 0 ? markers.stroke(self, i) : markers.fill(self, i);
      onMouse("click", label, (e) => {
        if (cursor._lock)
          return;
        setCursorEvent(e);
        let seriesIdx = series.indexOf(s);
        if ((e.ctrlKey || e.metaKey) != legend.isolate) {
          let isolate = series.some((s2, i2) => i2 > 0 && i2 != seriesIdx && s2.show);
          series.forEach((s2, i2) => {
            i2 > 0 && setSeries(i2, isolate ? i2 == seriesIdx ? son : soff : son, true, syncOpts.setSeries);
          });
        } else
          setSeries(seriesIdx, { show: !s.show }, true, syncOpts.setSeries);
      }, false);
      if (cursorFocus) {
        onMouse(mouseenter, label, (e) => {
          if (cursor._lock)
            return;
          setCursorEvent(e);
          setSeries(series.indexOf(s), FOCUS_TRUE, true, syncOpts.setSeries);
        }, false);
      }
    }
    for (var key2 in legendCols) {
      let v = placeTag("td", LEGEND_VALUE, row);
      v.textContent = "--";
      cells.push(v);
    }
    return [row, cells];
  }
  const mouseListeners = /* @__PURE__ */ new Map();
  function onMouse(ev, targ, fn, onlyTarg = true) {
    const targListeners = mouseListeners.get(targ) || {};
    const listener = cursor.bind[ev](self, targ, fn, onlyTarg);
    if (listener) {
      on(ev, targ, targListeners[ev] = listener);
      mouseListeners.set(targ, targListeners);
    }
  }
  function offMouse(ev, targ, fn) {
    const targListeners = mouseListeners.get(targ) || {};
    for (let k in targListeners) {
      if (ev == null || k == ev) {
        off(k, targ, targListeners[k]);
        delete targListeners[k];
      }
    }
    if (ev == null)
      mouseListeners.delete(targ);
  }
  let fullWidCss = 0;
  let fullHgtCss = 0;
  let plotWidCss = 0;
  let plotHgtCss = 0;
  let plotLftCss = 0;
  let plotTopCss = 0;
  let _plotLftCss = plotLftCss;
  let _plotTopCss = plotTopCss;
  let _plotWidCss = plotWidCss;
  let _plotHgtCss = plotHgtCss;
  let plotLft = 0;
  let plotTop = 0;
  let plotWid = 0;
  let plotHgt = 0;
  self.bbox = {};
  let shouldSetScales = false;
  let shouldSetSize = false;
  let shouldConvergeSize = false;
  let shouldSetCursor = false;
  let shouldSetSelect = false;
  let shouldSetLegend = false;
  function _setSize(width, height, force) {
    if (force || (width != self.width || height != self.height))
      calcSize(width, height);
    resetYSeries(false);
    shouldConvergeSize = true;
    shouldSetSize = true;
    commit();
  }
  function calcSize(width, height) {
    self.width = fullWidCss = plotWidCss = width;
    self.height = fullHgtCss = plotHgtCss = height;
    plotLftCss = plotTopCss = 0;
    calcPlotRect();
    calcAxesRects();
    let bb = self.bbox;
    plotLft = bb.left = incrRound(plotLftCss * pxRatio, 0.5);
    plotTop = bb.top = incrRound(plotTopCss * pxRatio, 0.5);
    plotWid = bb.width = incrRound(plotWidCss * pxRatio, 0.5);
    plotHgt = bb.height = incrRound(plotHgtCss * pxRatio, 0.5);
  }
  const CYCLE_LIMIT = 3;
  function convergeSize() {
    let converged = false;
    let cycleNum = 0;
    while (!converged) {
      cycleNum++;
      let axesConverged = axesCalc(cycleNum);
      let paddingConverged = paddingCalc(cycleNum);
      converged = cycleNum == CYCLE_LIMIT || axesConverged && paddingConverged;
      if (!converged) {
        calcSize(self.width, self.height);
        shouldSetSize = true;
      }
    }
  }
  function setSize({ width, height }) {
    _setSize(width, height);
  }
  self.setSize = setSize;
  function calcPlotRect() {
    let hasTopAxis = false;
    let hasBtmAxis = false;
    let hasRgtAxis = false;
    let hasLftAxis = false;
    axes.forEach((axis, i) => {
      if (axis.show && axis._show) {
        let { side, _size } = axis;
        let isVt = side % 2;
        let labelSize = axis.label != null ? axis.labelSize : 0;
        let fullSize = _size + labelSize;
        if (fullSize > 0) {
          if (isVt) {
            plotWidCss -= fullSize;
            if (side == 3) {
              plotLftCss += fullSize;
              hasLftAxis = true;
            } else
              hasRgtAxis = true;
          } else {
            plotHgtCss -= fullSize;
            if (side == 0) {
              plotTopCss += fullSize;
              hasTopAxis = true;
            } else
              hasBtmAxis = true;
          }
        }
      }
    });
    sidesWithAxes[0] = hasTopAxis;
    sidesWithAxes[1] = hasRgtAxis;
    sidesWithAxes[2] = hasBtmAxis;
    sidesWithAxes[3] = hasLftAxis;
    plotWidCss -= _padding[1] + _padding[3];
    plotLftCss += _padding[3];
    plotHgtCss -= _padding[2] + _padding[0];
    plotTopCss += _padding[0];
  }
  function calcAxesRects() {
    let off1 = plotLftCss + plotWidCss;
    let off2 = plotTopCss + plotHgtCss;
    let off3 = plotLftCss;
    let off0 = plotTopCss;
    function incrOffset(side, size3) {
      switch (side) {
        case 1:
          off1 += size3;
          return off1 - size3;
        case 2:
          off2 += size3;
          return off2 - size3;
        case 3:
          off3 -= size3;
          return off3 + size3;
        case 0:
          off0 -= size3;
          return off0 + size3;
      }
    }
    axes.forEach((axis, i) => {
      if (axis.show && axis._show) {
        let side = axis.side;
        axis._pos = incrOffset(side, axis._size);
        if (axis.label != null)
          axis._lpos = incrOffset(side, axis.labelSize);
      }
    });
  }
  if (cursor.dataIdx == null) {
    let hov = cursor.hover;
    let skip = hov.skip = new Set(hov.skip ?? []);
    skip.add(void 0);
    let prox = hov.prox = fnOrSelf(hov.prox);
    let bias = hov.bias ??= 0;
    cursor.dataIdx = (self2, seriesIdx, cursorIdx, valAtPosX) => {
      if (seriesIdx == 0)
        return cursorIdx;
      let idx2 = cursorIdx;
      let _prox = prox(self2, seriesIdx, cursorIdx, valAtPosX) ?? inf;
      let withProx = _prox >= 0 && _prox < inf;
      let xDim = scaleX.ori == 0 ? plotWidCss : plotHgtCss;
      let cursorLft = cursor.left;
      let xValues = data[0];
      let yValues = data[seriesIdx];
      if (skip.has(yValues[cursorIdx])) {
        idx2 = null;
        let nonNullLft = null, nonNullRgt = null, j;
        if (bias == 0 || bias == -1) {
          j = cursorIdx;
          while (nonNullLft == null && j-- > 0) {
            if (!skip.has(yValues[j]))
              nonNullLft = j;
          }
        }
        if (bias == 0 || bias == 1) {
          j = cursorIdx;
          while (nonNullRgt == null && j++ < yValues.length) {
            if (!skip.has(yValues[j]))
              nonNullRgt = j;
          }
        }
        if (nonNullLft != null || nonNullRgt != null) {
          if (withProx) {
            let lftPos = nonNullLft == null ? -Infinity : valToPosX(xValues[nonNullLft], scaleX, xDim, 0);
            let rgtPos = nonNullRgt == null ? Infinity : valToPosX(xValues[nonNullRgt], scaleX, xDim, 0);
            let lftDelta = cursorLft - lftPos;
            let rgtDelta = rgtPos - cursorLft;
            if (lftDelta <= rgtDelta) {
              if (lftDelta <= _prox)
                idx2 = nonNullLft;
            } else {
              if (rgtDelta <= _prox)
                idx2 = nonNullRgt;
            }
          } else {
            idx2 = nonNullRgt == null ? nonNullLft : nonNullLft == null ? nonNullRgt : cursorIdx - nonNullLft <= nonNullRgt - cursorIdx ? nonNullLft : nonNullRgt;
          }
        }
      } else if (withProx) {
        let dist = abs(cursorLft - valToPosX(xValues[cursorIdx], scaleX, xDim, 0));
        if (dist > _prox)
          idx2 = null;
      }
      return idx2;
    };
  }
  const setCursorEvent = (e) => {
    cursor.event = e;
  };
  cursor.idxs = activeIdxs;
  cursor._lock = false;
  let points2 = cursor.points;
  points2.show = fnOrSelf(points2.show);
  points2.size = fnOrSelf(points2.size);
  points2.stroke = fnOrSelf(points2.stroke);
  points2.width = fnOrSelf(points2.width);
  points2.fill = fnOrSelf(points2.fill);
  const focus = self.focus = assign({}, opts.focus || { alpha: 0.3 }, cursor.focus);
  const cursorFocus = focus.prox >= 0;
  const cursorOnePt = cursorFocus && points2.one;
  let cursorPts = [];
  let cursorPtsLft = [];
  let cursorPtsTop = [];
  function initCursorPt(s, si) {
    let pt = points2.show(self, si);
    if (pt instanceof HTMLElement) {
      addClass(pt, CURSOR_PT);
      addClass(pt, s.class);
      elTrans(pt, -10, -10, plotWidCss, plotHgtCss);
      over.insertBefore(pt, cursorPts[si]);
      return pt;
    }
  }
  function initSeries(s, i) {
    if (mode == 1 || i > 0) {
      let isTime = mode == 1 && scales[s.scale].time;
      let sv = s.value;
      s.value = isTime ? isStr(sv) ? timeSeriesVal(_tzDate, timeSeriesStamp(sv, _fmtDate)) : sv || _timeSeriesVal : sv || numSeriesVal;
      s.label = s.label || (isTime ? timeSeriesLabel : numSeriesLabel);
    }
    if (cursorOnePt || i > 0) {
      s.width = s.width == null ? 1 : s.width;
      s.paths = s.paths || linearPath || retNull;
      s.fillTo = fnOrSelf(s.fillTo || seriesFillTo);
      s.pxAlign = +ifNull(s.pxAlign, pxAlign);
      s.pxRound = pxRoundGen(s.pxAlign);
      s.stroke = fnOrSelf(s.stroke || null);
      s.fill = fnOrSelf(s.fill || null);
      s._stroke = s._fill = s._paths = s._focus = null;
      let _ptDia = ptDia(max2(1, s.width), 1);
      let points3 = s.points = assign({}, {
        size: _ptDia,
        width: max2(1, _ptDia * 0.2),
        stroke: s.stroke,
        space: _ptDia * 2,
        paths: pointsPath,
        _stroke: null,
        _fill: null
      }, s.points);
      points3.show = fnOrSelf(points3.show);
      points3.filter = fnOrSelf(points3.filter);
      points3.fill = fnOrSelf(points3.fill);
      points3.stroke = fnOrSelf(points3.stroke);
      points3.paths = fnOrSelf(points3.paths);
      points3.pxAlign = s.pxAlign;
    }
    if (showLegend) {
      let rowCells = initLegendRow(s, i);
      legendRows.splice(i, 0, rowCells[0]);
      legendCells.splice(i, 0, rowCells[1]);
      legend.values.push(null);
    }
    if (showCursor) {
      activeIdxs.splice(i, 0, null);
      let pt = null;
      if (cursorOnePt) {
        if (i == 0)
          pt = initCursorPt(s, i);
      } else if (i > 0)
        pt = initCursorPt(s, i);
      cursorPts.splice(i, 0, pt);
      cursorPtsLft.splice(i, 0, 0);
      cursorPtsTop.splice(i, 0, 0);
    }
    fire("addSeries", i);
  }
  function addSeries(opts2, si) {
    si = si == null ? series.length : si;
    opts2 = mode == 1 ? setDefault(opts2, si, xSeriesOpts, ySeriesOpts) : setDefault(opts2, si, {}, xySeriesOpts);
    series.splice(si, 0, opts2);
    initSeries(series[si], si);
  }
  self.addSeries = addSeries;
  function delSeries(i) {
    series.splice(i, 1);
    if (showLegend) {
      legend.values.splice(i, 1);
      legendCells.splice(i, 1);
      let tr = legendRows.splice(i, 1)[0];
      offMouse(null, tr.firstChild);
      tr.remove();
    }
    if (showCursor) {
      activeIdxs.splice(i, 1);
      cursorPts.splice(i, 1)[0].remove();
      cursorPtsLft.splice(i, 1);
      cursorPtsTop.splice(i, 1);
    }
    fire("delSeries", i);
  }
  self.delSeries = delSeries;
  const sidesWithAxes = [false, false, false, false];
  function initAxis(axis, i) {
    axis._show = axis.show;
    if (axis.show) {
      let isVt = axis.side % 2;
      let sc = scales[axis.scale];
      if (sc == null) {
        axis.scale = isVt ? series[1].scale : xScaleKey;
        sc = scales[axis.scale];
      }
      let isTime = sc.time;
      axis.size = fnOrSelf(axis.size);
      axis.space = fnOrSelf(axis.space);
      axis.rotate = fnOrSelf(axis.rotate);
      if (isArr(axis.incrs)) {
        axis.incrs.forEach((incr) => {
          !fixedDec.has(incr) && fixedDec.set(incr, guessDec(incr));
        });
      }
      axis.incrs = fnOrSelf(axis.incrs || (sc.distr == 2 ? wholeIncrs : isTime ? ms == 1 ? timeIncrsMs : timeIncrsS : numIncrs));
      axis.splits = fnOrSelf(axis.splits || (isTime && sc.distr == 1 ? _timeAxisSplits : sc.distr == 3 ? logAxisSplits : sc.distr == 4 ? asinhAxisSplits : numAxisSplits));
      axis.stroke = fnOrSelf(axis.stroke);
      axis.grid.stroke = fnOrSelf(axis.grid.stroke);
      axis.ticks.stroke = fnOrSelf(axis.ticks.stroke);
      axis.border.stroke = fnOrSelf(axis.border.stroke);
      let av = axis.values;
      axis.values = // static array of tick values
      isArr(av) && !isArr(av[0]) ? fnOrSelf(av) : (
        // temporal
        isTime ? (
          // config array of fmtDate string tpls
          isArr(av) ? timeAxisVals(_tzDate, timeAxisStamps(av, _fmtDate)) : (
            // fmtDate string tpl
            isStr(av) ? timeAxisVal(_tzDate, av) : av || _timeAxisVals
          )
        ) : av || numAxisVals
      );
      axis.filter = fnOrSelf(axis.filter || (sc.distr >= 3 && sc.log == 10 ? log10AxisValsFilt : sc.distr == 3 && sc.log == 2 ? log2AxisValsFilt : retArg1));
      axis.font = pxRatioFont(axis.font);
      axis.labelFont = pxRatioFont(axis.labelFont);
      axis._size = axis.size(self, null, i, 0);
      axis._space = axis._rotate = axis._incrs = axis._found = // foundIncrSpace
      axis._splits = axis._values = null;
      if (axis._size > 0) {
        sidesWithAxes[i] = true;
        axis._el = placeDiv(AXIS, wrap);
      }
    }
  }
  function autoPadSide(self2, side, sidesWithAxes2, cycleNum) {
    let [hasTopAxis, hasRgtAxis, hasBtmAxis, hasLftAxis] = sidesWithAxes2;
    let ori = side % 2;
    let size3 = 0;
    if (ori == 0 && (hasLftAxis || hasRgtAxis))
      size3 = side == 0 && !hasTopAxis || side == 2 && !hasBtmAxis ? round2(xAxisOpts.size / 3) : 0;
    if (ori == 1 && (hasTopAxis || hasBtmAxis))
      size3 = side == 1 && !hasRgtAxis || side == 3 && !hasLftAxis ? round2(yAxisOpts.size / 2) : 0;
    return size3;
  }
  const padding = self.padding = (opts.padding || [autoPadSide, autoPadSide, autoPadSide, autoPadSide]).map((p) => fnOrSelf(ifNull(p, autoPadSide)));
  const _padding = self._padding = padding.map((p, i) => p(self, i, sidesWithAxes, 0));
  let dataLen;
  let i0 = null;
  let i1 = null;
  const idxs = mode == 1 ? series[0].idxs : null;
  let data0 = null;
  let viaAutoScaleX = false;
  function setData(_data, _resetScales) {
    data = _data == null ? [] : _data;
    self.data = self._data = data;
    if (mode == 2) {
      dataLen = 0;
      for (let i = 1; i < series.length; i++)
        dataLen += data[i][0].length;
    } else {
      if (data.length == 0)
        self.data = self._data = data = [[]];
      data0 = data[0];
      dataLen = data0.length;
      let scaleData = data;
      if (xScaleDistr == 2) {
        scaleData = data.slice();
        let _data0 = scaleData[0] = Array(dataLen);
        for (let i = 0; i < dataLen; i++)
          _data0[i] = i;
      }
      self._data = data = scaleData;
    }
    resetYSeries(true);
    fire("setData");
    if (xScaleDistr == 2) {
      shouldConvergeSize = true;
    }
    if (_resetScales !== false) {
      let xsc = scaleX;
      if (xsc.auto(self, viaAutoScaleX))
        autoScaleX();
      else
        _setScale(xScaleKey, xsc.min, xsc.max);
      shouldSetCursor = shouldSetCursor || cursor.left >= 0;
      shouldSetLegend = true;
      commit();
    }
  }
  self.setData = setData;
  function autoScaleX() {
    viaAutoScaleX = true;
    let _min, _max;
    if (mode == 1) {
      if (dataLen > 0) {
        i0 = idxs[0] = 0;
        i1 = idxs[1] = dataLen - 1;
        _min = data[0][i0];
        _max = data[0][i1];
        if (xScaleDistr == 2) {
          _min = i0;
          _max = i1;
        } else if (_min == _max) {
          if (xScaleDistr == 3)
            [_min, _max] = rangeLog(_min, _min, scaleX.log, false);
          else if (xScaleDistr == 4)
            [_min, _max] = rangeAsinh(_min, _min, scaleX.log, false);
          else if (scaleX.time)
            _max = _min + round2(86400 / ms);
          else
            [_min, _max] = rangeNum(_min, _max, rangePad, true);
        }
      } else {
        i0 = idxs[0] = _min = null;
        i1 = idxs[1] = _max = null;
      }
    }
    _setScale(xScaleKey, _min, _max);
  }
  let ctxStroke, ctxFill, ctxWidth, ctxDash, ctxJoin, ctxCap, ctxFont, ctxAlign, ctxBaseline;
  let ctxAlpha;
  function setCtxStyle(stroke, width, dash, cap, fill, join2) {
    stroke ??= transparent;
    dash ??= EMPTY_ARR;
    cap ??= "butt";
    fill ??= transparent;
    join2 ??= "round";
    if (stroke != ctxStroke)
      ctx.strokeStyle = ctxStroke = stroke;
    if (fill != ctxFill)
      ctx.fillStyle = ctxFill = fill;
    if (width != ctxWidth)
      ctx.lineWidth = ctxWidth = width;
    if (join2 != ctxJoin)
      ctx.lineJoin = ctxJoin = join2;
    if (cap != ctxCap)
      ctx.lineCap = ctxCap = cap;
    if (dash != ctxDash)
      ctx.setLineDash(ctxDash = dash);
  }
  function setFontStyle(font2, fill, align, baseline) {
    if (fill != ctxFill)
      ctx.fillStyle = ctxFill = fill;
    if (font2 != ctxFont)
      ctx.font = ctxFont = font2;
    if (align != ctxAlign)
      ctx.textAlign = ctxAlign = align;
    if (baseline != ctxBaseline)
      ctx.textBaseline = ctxBaseline = baseline;
  }
  function accScale(wsc, psc, facet2, data2, sorted = 0) {
    if (data2.length > 0 && wsc.auto(self, viaAutoScaleX) && (psc == null || psc.min == null)) {
      let _i0 = ifNull(i0, 0);
      let _i1 = ifNull(i1, data2.length - 1);
      let minMax = facet2.min == null ? getMinMax(data2, _i0, _i1, sorted, wsc.distr == 3) : [facet2.min, facet2.max];
      wsc.min = min2(wsc.min, facet2.min = minMax[0]);
      wsc.max = max2(wsc.max, facet2.max = minMax[1]);
    }
  }
  const AUTOSCALE = { min: null, max: null };
  function setScales() {
    for (let k in scales) {
      let sc = scales[k];
      if (pendScales[k] == null && // scales that have never been set (on init)
      (sc.min == null || // or auto scales when the x scale was explicitly set
      pendScales[xScaleKey] != null && sc.auto(self, viaAutoScaleX))) {
        pendScales[k] = AUTOSCALE;
      }
    }
    for (let k in scales) {
      let sc = scales[k];
      if (pendScales[k] == null && sc.from != null && pendScales[sc.from] != null)
        pendScales[k] = AUTOSCALE;
    }
    if (pendScales[xScaleKey] != null)
      resetYSeries(true);
    let wipScales = {};
    for (let k in pendScales) {
      let psc = pendScales[k];
      if (psc != null) {
        let wsc = wipScales[k] = copy(scales[k], fastIsObj);
        if (psc.min != null)
          assign(wsc, psc);
        else if (k != xScaleKey || mode == 2) {
          if (dataLen == 0 && wsc.from == null) {
            let minMax = wsc.range(self, null, null, k);
            wsc.min = minMax[0];
            wsc.max = minMax[1];
          } else {
            wsc.min = inf;
            wsc.max = -inf;
          }
        }
      }
    }
    if (dataLen > 0) {
      series.forEach((s, i) => {
        if (mode == 1) {
          let k = s.scale;
          let psc = pendScales[k];
          if (psc == null)
            return;
          let wsc = wipScales[k];
          if (i == 0) {
            let minMax = wsc.range(self, wsc.min, wsc.max, k);
            wsc.min = minMax[0];
            wsc.max = minMax[1];
            i0 = closestIdx(wsc.min, data[0]);
            i1 = closestIdx(wsc.max, data[0]);
            if (i1 - i0 > 1) {
              if (data[0][i0] < wsc.min)
                i0++;
              if (data[0][i1] > wsc.max)
                i1--;
            }
            s.min = data0[i0];
            s.max = data0[i1];
          } else if (s.show && s.auto)
            accScale(wsc, psc, s, data[i], s.sorted);
          s.idxs[0] = i0;
          s.idxs[1] = i1;
        } else {
          if (i > 0) {
            if (s.show && s.auto) {
              let [xFacet, yFacet] = s.facets;
              let xScaleKey2 = xFacet.scale;
              let yScaleKey = yFacet.scale;
              let [xData, yData] = data[i];
              let wscx = wipScales[xScaleKey2];
              let wscy = wipScales[yScaleKey];
              wscx != null && accScale(wscx, pendScales[xScaleKey2], xFacet, xData, xFacet.sorted);
              wscy != null && accScale(wscy, pendScales[yScaleKey], yFacet, yData, yFacet.sorted);
              s.min = yFacet.min;
              s.max = yFacet.max;
            }
          }
        }
      });
      for (let k in wipScales) {
        let wsc = wipScales[k];
        let psc = pendScales[k];
        if (wsc.from == null && (psc == null || psc.min == null)) {
          let minMax = wsc.range(
            self,
            wsc.min == inf ? null : wsc.min,
            wsc.max == -inf ? null : wsc.max,
            k
          );
          wsc.min = minMax[0];
          wsc.max = minMax[1];
        }
      }
    }
    for (let k in wipScales) {
      let wsc = wipScales[k];
      if (wsc.from != null) {
        let base = wipScales[wsc.from];
        if (base.min == null)
          wsc.min = wsc.max = null;
        else {
          let minMax = wsc.range(self, base.min, base.max, k);
          wsc.min = minMax[0];
          wsc.max = minMax[1];
        }
      }
    }
    let changed = {};
    let anyChanged = false;
    for (let k in wipScales) {
      let wsc = wipScales[k];
      let sc = scales[k];
      if (sc.min != wsc.min || sc.max != wsc.max) {
        sc.min = wsc.min;
        sc.max = wsc.max;
        let distr = sc.distr;
        sc._min = distr == 3 ? log10(sc.min) : distr == 4 ? asinh(sc.min, sc.asinh) : distr == 100 ? sc.fwd(sc.min) : sc.min;
        sc._max = distr == 3 ? log10(sc.max) : distr == 4 ? asinh(sc.max, sc.asinh) : distr == 100 ? sc.fwd(sc.max) : sc.max;
        changed[k] = anyChanged = true;
      }
    }
    if (anyChanged) {
      series.forEach((s, i) => {
        if (mode == 2) {
          if (i > 0 && changed.y)
            s._paths = null;
        } else {
          if (changed[s.scale])
            s._paths = null;
        }
      });
      for (let k in changed) {
        shouldConvergeSize = true;
        fire("setScale", k);
      }
      if (showCursor && cursor.left >= 0)
        shouldSetCursor = shouldSetLegend = true;
    }
    for (let k in pendScales)
      pendScales[k] = null;
  }
  function getOuterIdxs(ydata) {
    let _i0 = clamp2(i0 - 1, 0, dataLen - 1);
    let _i1 = clamp2(i1 + 1, 0, dataLen - 1);
    while (ydata[_i0] == null && _i0 > 0)
      _i0--;
    while (ydata[_i1] == null && _i1 < dataLen - 1)
      _i1++;
    return [_i0, _i1];
  }
  function drawSeries() {
    if (dataLen > 0) {
      let shouldAlpha = series.some((s) => s._focus) && ctxAlpha != focus.alpha;
      if (shouldAlpha)
        ctx.globalAlpha = ctxAlpha = focus.alpha;
      series.forEach((s, i) => {
        if (i > 0 && s.show) {
          cacheStrokeFill(i, false);
          cacheStrokeFill(i, true);
          if (s._paths == null) {
            let _ctxAlpha = ctxAlpha;
            if (ctxAlpha != s.alpha)
              ctx.globalAlpha = ctxAlpha = s.alpha;
            let _idxs = mode == 2 ? [0, data[i][0].length - 1] : getOuterIdxs(data[i]);
            s._paths = s.paths(self, i, _idxs[0], _idxs[1]);
            if (ctxAlpha != _ctxAlpha)
              ctx.globalAlpha = ctxAlpha = _ctxAlpha;
          }
        }
      });
      series.forEach((s, i) => {
        if (i > 0 && s.show) {
          let _ctxAlpha = ctxAlpha;
          if (ctxAlpha != s.alpha)
            ctx.globalAlpha = ctxAlpha = s.alpha;
          s._paths != null && drawPath(i, false);
          {
            let _gaps = s._paths != null ? s._paths.gaps : null;
            let show = s.points.show(self, i, i0, i1, _gaps);
            let idxs2 = s.points.filter(self, i, show, _gaps);
            if (show || idxs2) {
              s.points._paths = s.points.paths(self, i, i0, i1, idxs2);
              drawPath(i, true);
            }
          }
          if (ctxAlpha != _ctxAlpha)
            ctx.globalAlpha = ctxAlpha = _ctxAlpha;
          fire("drawSeries", i);
        }
      });
      if (shouldAlpha)
        ctx.globalAlpha = ctxAlpha = 1;
    }
  }
  function cacheStrokeFill(si, _points) {
    let s = _points ? series[si].points : series[si];
    s._stroke = s.stroke(self, si);
    s._fill = s.fill(self, si);
  }
  function drawPath(si, _points) {
    let s = _points ? series[si].points : series[si];
    let {
      stroke,
      fill,
      clip: gapsClip,
      flags,
      _stroke: strokeStyle = s._stroke,
      _fill: fillStyle = s._fill,
      _width: width = s.width
    } = s._paths;
    width = roundDec(width * pxRatio, 3);
    let boundsClip = null;
    let offset3 = width % 2 / 2;
    if (_points && fillStyle == null)
      fillStyle = width > 0 ? "#fff" : strokeStyle;
    let _pxAlign = s.pxAlign == 1 && offset3 > 0;
    _pxAlign && ctx.translate(offset3, offset3);
    if (!_points) {
      let lft = plotLft - width / 2, top = plotTop - width / 2, wid = plotWid + width, hgt = plotHgt + width;
      boundsClip = new Path2D();
      boundsClip.rect(lft, top, wid, hgt);
    }
    if (_points)
      strokeFill(strokeStyle, width, s.dash, s.cap, fillStyle, stroke, fill, flags, gapsClip);
    else
      fillStroke(si, strokeStyle, width, s.dash, s.cap, fillStyle, stroke, fill, flags, boundsClip, gapsClip);
    _pxAlign && ctx.translate(-offset3, -offset3);
  }
  function fillStroke(si, strokeStyle, lineWidth, lineDash, lineCap, fillStyle, strokePath, fillPath, flags, boundsClip, gapsClip) {
    let didStrokeFill = false;
    flags != 0 && bands.forEach((b, bi) => {
      if (b.series[0] == si) {
        let lowerEdge = series[b.series[1]];
        let lowerData = data[b.series[1]];
        let bandClip = (lowerEdge._paths || EMPTY_OBJ).band;
        if (isArr(bandClip))
          bandClip = b.dir == 1 ? bandClip[0] : bandClip[1];
        let gapsClip2;
        let _fillStyle = null;
        if (lowerEdge.show && bandClip && hasData(lowerData, i0, i1)) {
          _fillStyle = b.fill(self, bi) || fillStyle;
          gapsClip2 = lowerEdge._paths.clip;
        } else
          bandClip = null;
        strokeFill(strokeStyle, lineWidth, lineDash, lineCap, _fillStyle, strokePath, fillPath, flags, boundsClip, gapsClip, gapsClip2, bandClip);
        didStrokeFill = true;
      }
    });
    if (!didStrokeFill)
      strokeFill(strokeStyle, lineWidth, lineDash, lineCap, fillStyle, strokePath, fillPath, flags, boundsClip, gapsClip);
  }
  const CLIP_FILL_STROKE = BAND_CLIP_FILL | BAND_CLIP_STROKE;
  function strokeFill(strokeStyle, lineWidth, lineDash, lineCap, fillStyle, strokePath, fillPath, flags, boundsClip, gapsClip, gapsClip2, bandClip) {
    setCtxStyle(strokeStyle, lineWidth, lineDash, lineCap, fillStyle);
    if (boundsClip || gapsClip || bandClip) {
      ctx.save();
      boundsClip && ctx.clip(boundsClip);
      gapsClip && ctx.clip(gapsClip);
    }
    if (bandClip) {
      if ((flags & CLIP_FILL_STROKE) == CLIP_FILL_STROKE) {
        ctx.clip(bandClip);
        gapsClip2 && ctx.clip(gapsClip2);
        doFill(fillStyle, fillPath);
        doStroke(strokeStyle, strokePath, lineWidth);
      } else if (flags & BAND_CLIP_STROKE) {
        doFill(fillStyle, fillPath);
        ctx.clip(bandClip);
        doStroke(strokeStyle, strokePath, lineWidth);
      } else if (flags & BAND_CLIP_FILL) {
        ctx.save();
        ctx.clip(bandClip);
        gapsClip2 && ctx.clip(gapsClip2);
        doFill(fillStyle, fillPath);
        ctx.restore();
        doStroke(strokeStyle, strokePath, lineWidth);
      }
    } else {
      doFill(fillStyle, fillPath);
      doStroke(strokeStyle, strokePath, lineWidth);
    }
    if (boundsClip || gapsClip || bandClip)
      ctx.restore();
  }
  function doStroke(strokeStyle, strokePath, lineWidth) {
    if (lineWidth > 0) {
      if (strokePath instanceof Map) {
        strokePath.forEach((strokePath2, strokeStyle2) => {
          ctx.strokeStyle = ctxStroke = strokeStyle2;
          ctx.stroke(strokePath2);
        });
      } else
        strokePath != null && strokeStyle && ctx.stroke(strokePath);
    }
  }
  function doFill(fillStyle, fillPath) {
    if (fillPath instanceof Map) {
      fillPath.forEach((fillPath2, fillStyle2) => {
        ctx.fillStyle = ctxFill = fillStyle2;
        ctx.fill(fillPath2);
      });
    } else
      fillPath != null && fillStyle && ctx.fill(fillPath);
  }
  function getIncrSpace(axisIdx, min3, max3, fullDim) {
    let axis = axes[axisIdx];
    let incrSpace;
    if (fullDim <= 0)
      incrSpace = [0, 0];
    else {
      let minSpace = axis._space = axis.space(self, axisIdx, min3, max3, fullDim);
      let incrs = axis._incrs = axis.incrs(self, axisIdx, min3, max3, fullDim, minSpace);
      incrSpace = findIncr(min3, max3, incrs, fullDim, minSpace);
    }
    return axis._found = incrSpace;
  }
  function drawOrthoLines(offs, filts, ori, side, pos0, len, width, stroke, dash, cap) {
    let offset3 = width % 2 / 2;
    pxAlign == 1 && ctx.translate(offset3, offset3);
    setCtxStyle(stroke, width, dash, cap, stroke);
    ctx.beginPath();
    let x0, y0, x1, y1, pos1 = pos0 + (side == 0 || side == 3 ? -len : len);
    if (ori == 0) {
      y0 = pos0;
      y1 = pos1;
    } else {
      x0 = pos0;
      x1 = pos1;
    }
    for (let i = 0; i < offs.length; i++) {
      if (filts[i] != null) {
        if (ori == 0)
          x0 = x1 = offs[i];
        else
          y0 = y1 = offs[i];
        ctx.moveTo(x0, y0);
        ctx.lineTo(x1, y1);
      }
    }
    ctx.stroke();
    pxAlign == 1 && ctx.translate(-offset3, -offset3);
  }
  function axesCalc(cycleNum) {
    let converged = true;
    axes.forEach((axis, i) => {
      if (!axis.show)
        return;
      let scale = scales[axis.scale];
      if (scale.min == null) {
        if (axis._show) {
          converged = false;
          axis._show = false;
          resetYSeries(false);
        }
        return;
      } else {
        if (!axis._show) {
          converged = false;
          axis._show = true;
          resetYSeries(false);
        }
      }
      let side = axis.side;
      let ori = side % 2;
      let { min: min3, max: max3 } = scale;
      let [_incr, _space] = getIncrSpace(i, min3, max3, ori == 0 ? plotWidCss : plotHgtCss);
      if (_space == 0)
        return;
      let forceMin = scale.distr == 2;
      let _splits = axis._splits = axis.splits(self, i, min3, max3, _incr, _space, forceMin);
      let splits = scale.distr == 2 ? _splits.map((i2) => data0[i2]) : _splits;
      let incr = scale.distr == 2 ? data0[_splits[1]] - data0[_splits[0]] : _incr;
      let values = axis._values = axis.values(self, axis.filter(self, splits, i, _space, incr), i, _space, incr);
      axis._rotate = side == 2 ? axis.rotate(self, values, i, _space) : 0;
      let oldSize = axis._size;
      axis._size = ceil(axis.size(self, values, i, cycleNum));
      if (oldSize != null && axis._size != oldSize)
        converged = false;
    });
    return converged;
  }
  function paddingCalc(cycleNum) {
    let converged = true;
    padding.forEach((p, i) => {
      let _p = p(self, i, sidesWithAxes, cycleNum);
      if (_p != _padding[i])
        converged = false;
      _padding[i] = _p;
    });
    return converged;
  }
  function drawAxesGrid() {
    for (let i = 0; i < axes.length; i++) {
      let axis = axes[i];
      if (!axis.show || !axis._show)
        continue;
      let side = axis.side;
      let ori = side % 2;
      let x, y;
      let fillStyle = axis.stroke(self, i);
      let shiftDir = side == 0 || side == 3 ? -1 : 1;
      let [_incr, _space] = axis._found;
      if (axis.label != null) {
        let shiftAmt2 = axis.labelGap * shiftDir;
        let baseLpos = round2((axis._lpos + shiftAmt2) * pxRatio);
        setFontStyle(axis.labelFont[0], fillStyle, "center", side == 2 ? TOP : BOTTOM);
        ctx.save();
        if (ori == 1) {
          x = y = 0;
          ctx.translate(
            baseLpos,
            round2(plotTop + plotHgt / 2)
          );
          ctx.rotate((side == 3 ? -PI : PI) / 2);
        } else {
          x = round2(plotLft + plotWid / 2);
          y = baseLpos;
        }
        let _label = isFn(axis.label) ? axis.label(self, i, _incr, _space) : axis.label;
        ctx.fillText(_label, x, y);
        ctx.restore();
      }
      if (_space == 0)
        continue;
      let scale = scales[axis.scale];
      let plotDim = ori == 0 ? plotWid : plotHgt;
      let plotOff = ori == 0 ? plotLft : plotTop;
      let _splits = axis._splits;
      let splits = scale.distr == 2 ? _splits.map((i2) => data0[i2]) : _splits;
      let incr = scale.distr == 2 ? data0[_splits[1]] - data0[_splits[0]] : _incr;
      let ticks2 = axis.ticks;
      let border2 = axis.border;
      let _tickSize = ticks2.show ? ticks2.size : 0;
      let tickSize = round2(_tickSize * pxRatio);
      let axisGap = round2((axis.alignTo == 2 ? axis._size - _tickSize - axis.gap : axis.gap) * pxRatio);
      let angle = axis._rotate * -PI / 180;
      let basePos = pxRound(axis._pos * pxRatio);
      let shiftAmt = (tickSize + axisGap) * shiftDir;
      let finalPos = basePos + shiftAmt;
      y = ori == 0 ? finalPos : 0;
      x = ori == 1 ? finalPos : 0;
      let font2 = axis.font[0];
      let textAlign = axis.align == 1 ? LEFT : axis.align == 2 ? RIGHT : angle > 0 ? LEFT : angle < 0 ? RIGHT : ori == 0 ? "center" : side == 3 ? RIGHT : LEFT;
      let textBaseline = angle || ori == 1 ? "middle" : side == 2 ? TOP : BOTTOM;
      setFontStyle(font2, fillStyle, textAlign, textBaseline);
      let lineHeight = axis.font[1] * axis.lineGap;
      let canOffs = _splits.map((val) => pxRound(getPos(val, scale, plotDim, plotOff)));
      let _values = axis._values;
      for (let i2 = 0; i2 < _values.length; i2++) {
        let val = _values[i2];
        if (val != null) {
          if (ori == 0)
            x = canOffs[i2];
          else
            y = canOffs[i2];
          val = "" + val;
          let _parts = val.indexOf("\n") == -1 ? [val] : val.split(/\n/gm);
          for (let j = 0; j < _parts.length; j++) {
            let text = _parts[j];
            if (angle) {
              ctx.save();
              ctx.translate(x, y + j * lineHeight);
              ctx.rotate(angle);
              ctx.fillText(text, 0, 0);
              ctx.restore();
            } else
              ctx.fillText(text, x, y + j * lineHeight);
          }
        }
      }
      if (ticks2.show) {
        drawOrthoLines(
          canOffs,
          ticks2.filter(self, splits, i, _space, incr),
          ori,
          side,
          basePos,
          tickSize,
          roundDec(ticks2.width * pxRatio, 3),
          ticks2.stroke(self, i),
          ticks2.dash,
          ticks2.cap
        );
      }
      let grid2 = axis.grid;
      if (grid2.show) {
        drawOrthoLines(
          canOffs,
          grid2.filter(self, splits, i, _space, incr),
          ori,
          ori == 0 ? 2 : 1,
          ori == 0 ? plotTop : plotLft,
          ori == 0 ? plotHgt : plotWid,
          roundDec(grid2.width * pxRatio, 3),
          grid2.stroke(self, i),
          grid2.dash,
          grid2.cap
        );
      }
      if (border2.show) {
        drawOrthoLines(
          [basePos],
          [1],
          ori == 0 ? 1 : 0,
          ori == 0 ? 1 : 2,
          ori == 1 ? plotTop : plotLft,
          ori == 1 ? plotHgt : plotWid,
          roundDec(border2.width * pxRatio, 3),
          border2.stroke(self, i),
          border2.dash,
          border2.cap
        );
      }
    }
    fire("drawAxes");
  }
  function resetYSeries(minMax) {
    series.forEach((s, i) => {
      if (i > 0) {
        s._paths = null;
        if (minMax) {
          if (mode == 1) {
            s.min = null;
            s.max = null;
          } else {
            s.facets.forEach((f) => {
              f.min = null;
              f.max = null;
            });
          }
        }
      }
    });
  }
  let queuedCommit = false;
  let deferHooks = false;
  let hooksQueue = [];
  function flushHooks() {
    deferHooks = false;
    for (let i = 0; i < hooksQueue.length; i++)
      fire(...hooksQueue[i]);
    hooksQueue.length = 0;
  }
  function commit() {
    if (!queuedCommit) {
      microTask(_commit);
      queuedCommit = true;
    }
  }
  function batch(fn, _deferHooks = false) {
    queuedCommit = true;
    deferHooks = _deferHooks;
    fn(self);
    _commit();
    if (_deferHooks && hooksQueue.length > 0)
      queueMicrotask(flushHooks);
  }
  self.batch = batch;
  function _commit() {
    if (shouldSetScales) {
      setScales();
      shouldSetScales = false;
    }
    if (shouldConvergeSize) {
      convergeSize();
      shouldConvergeSize = false;
    }
    if (shouldSetSize) {
      setStylePx(under, LEFT, plotLftCss);
      setStylePx(under, TOP, plotTopCss);
      setStylePx(under, WIDTH, plotWidCss);
      setStylePx(under, HEIGHT, plotHgtCss);
      setStylePx(over, LEFT, plotLftCss);
      setStylePx(over, TOP, plotTopCss);
      setStylePx(over, WIDTH, plotWidCss);
      setStylePx(over, HEIGHT, plotHgtCss);
      setStylePx(wrap, WIDTH, fullWidCss);
      setStylePx(wrap, HEIGHT, fullHgtCss);
      can.width = round2(fullWidCss * pxRatio);
      can.height = round2(fullHgtCss * pxRatio);
      axes.forEach(({ _el, _show, _size, _pos, side }) => {
        if (_el != null) {
          if (_show) {
            let posOffset = side === 3 || side === 0 ? _size : 0;
            let isVt = side % 2 == 1;
            setStylePx(_el, isVt ? "left" : "top", _pos - posOffset);
            setStylePx(_el, isVt ? "width" : "height", _size);
            setStylePx(_el, isVt ? "top" : "left", isVt ? plotTopCss : plotLftCss);
            setStylePx(_el, isVt ? "height" : "width", isVt ? plotHgtCss : plotWidCss);
            remClass(_el, OFF);
          } else
            addClass(_el, OFF);
        }
      });
      ctxStroke = ctxFill = ctxWidth = ctxJoin = ctxCap = ctxFont = ctxAlign = ctxBaseline = ctxDash = null;
      ctxAlpha = 1;
      syncRect(true);
      if (plotLftCss != _plotLftCss || plotTopCss != _plotTopCss || plotWidCss != _plotWidCss || plotHgtCss != _plotHgtCss) {
        resetYSeries(false);
        let pctWid = plotWidCss / _plotWidCss;
        let pctHgt = plotHgtCss / _plotHgtCss;
        if (showCursor && !shouldSetCursor && cursor.left >= 0) {
          cursor.left *= pctWid;
          cursor.top *= pctHgt;
          vCursor && elTrans(vCursor, round2(cursor.left), 0, plotWidCss, plotHgtCss);
          hCursor && elTrans(hCursor, 0, round2(cursor.top), plotWidCss, plotHgtCss);
          for (let i = 0; i < cursorPts.length; i++) {
            let pt = cursorPts[i];
            if (pt != null) {
              cursorPtsLft[i] *= pctWid;
              cursorPtsTop[i] *= pctHgt;
              elTrans(pt, ceil(cursorPtsLft[i]), ceil(cursorPtsTop[i]), plotWidCss, plotHgtCss);
            }
          }
        }
        if (select.show && !shouldSetSelect && select.left >= 0 && select.width > 0) {
          select.left *= pctWid;
          select.width *= pctWid;
          select.top *= pctHgt;
          select.height *= pctHgt;
          for (let prop in _hideProps)
            setStylePx(selectDiv, prop, select[prop]);
        }
        _plotLftCss = plotLftCss;
        _plotTopCss = plotTopCss;
        _plotWidCss = plotWidCss;
        _plotHgtCss = plotHgtCss;
      }
      fire("setSize");
      shouldSetSize = false;
    }
    if (fullWidCss > 0 && fullHgtCss > 0) {
      ctx.clearRect(0, 0, can.width, can.height);
      fire("drawClear");
      drawOrder.forEach((fn) => fn());
      fire("draw");
    }
    if (select.show && shouldSetSelect) {
      setSelect(select);
      shouldSetSelect = false;
    }
    if (showCursor && shouldSetCursor) {
      updateCursor(null, true, false);
      shouldSetCursor = false;
    }
    if (legend.show && legend.live && shouldSetLegend) {
      setLegend();
      shouldSetLegend = false;
    }
    if (!ready) {
      ready = true;
      self.status = 1;
      fire("ready");
    }
    viaAutoScaleX = false;
    queuedCommit = false;
  }
  self.redraw = (rebuildPaths, recalcAxes) => {
    shouldConvergeSize = recalcAxes || false;
    if (rebuildPaths !== false)
      _setScale(xScaleKey, scaleX.min, scaleX.max);
    else
      commit();
  };
  function setScale(key2, opts2) {
    let sc = scales[key2];
    if (sc.from == null) {
      if (dataLen == 0) {
        let minMax = sc.range(self, opts2.min, opts2.max, key2);
        opts2.min = minMax[0];
        opts2.max = minMax[1];
      }
      if (opts2.min > opts2.max) {
        let _min = opts2.min;
        opts2.min = opts2.max;
        opts2.max = _min;
      }
      if (dataLen > 1 && opts2.min != null && opts2.max != null && opts2.max - opts2.min < 1e-16)
        return;
      if (key2 == xScaleKey) {
        if (sc.distr == 2 && dataLen > 0) {
          opts2.min = closestIdx(opts2.min, data[0]);
          opts2.max = closestIdx(opts2.max, data[0]);
          if (opts2.min == opts2.max)
            opts2.max++;
        }
      }
      pendScales[key2] = opts2;
      shouldSetScales = true;
      commit();
    }
  }
  self.setScale = setScale;
  let xCursor;
  let yCursor;
  let vCursor;
  let hCursor;
  let rawMouseLeft0;
  let rawMouseTop0;
  let mouseLeft0;
  let mouseTop0;
  let rawMouseLeft1;
  let rawMouseTop1;
  let mouseLeft1;
  let mouseTop1;
  let dragging = false;
  const drag = cursor.drag;
  let dragX = drag.x;
  let dragY = drag.y;
  if (showCursor) {
    if (cursor.x)
      xCursor = placeDiv(CURSOR_X, over);
    if (cursor.y)
      yCursor = placeDiv(CURSOR_Y, over);
    if (scaleX.ori == 0) {
      vCursor = xCursor;
      hCursor = yCursor;
    } else {
      vCursor = yCursor;
      hCursor = xCursor;
    }
    mouseLeft1 = cursor.left;
    mouseTop1 = cursor.top;
  }
  const select = self.select = assign({
    show: true,
    over: true,
    left: 0,
    width: 0,
    top: 0,
    height: 0
  }, opts.select);
  const selectDiv = select.show ? placeDiv(SELECT, select.over ? over : under) : null;
  function setSelect(opts2, _fire) {
    if (select.show) {
      for (let prop in opts2) {
        select[prop] = opts2[prop];
        if (prop in _hideProps)
          setStylePx(selectDiv, prop, opts2[prop]);
      }
      _fire !== false && fire("setSelect");
    }
  }
  self.setSelect = setSelect;
  function toggleDOM(i) {
    let s = series[i];
    if (s.show)
      showLegend && remClass(legendRows[i], OFF);
    else {
      showLegend && addClass(legendRows[i], OFF);
      if (showCursor) {
        let pt = cursorOnePt ? cursorPts[0] : cursorPts[i];
        pt != null && elTrans(pt, -10, -10, plotWidCss, plotHgtCss);
      }
    }
  }
  function _setScale(key2, min3, max3) {
    setScale(key2, { min: min3, max: max3 });
  }
  function setSeries(i, opts2, _fire, _pub) {
    if (opts2.focus != null)
      setFocus(i);
    if (opts2.show != null) {
      series.forEach((s, si) => {
        if (si > 0 && (i == si || i == null)) {
          s.show = opts2.show;
          toggleDOM(si);
          if (mode == 2) {
            _setScale(s.facets[0].scale, null, null);
            _setScale(s.facets[1].scale, null, null);
          } else
            _setScale(s.scale, null, null);
          commit();
        }
      });
    }
    _fire !== false && fire("setSeries", i, opts2);
    _pub && pubSync("setSeries", self, i, opts2);
  }
  self.setSeries = setSeries;
  function setBand(bi, opts2) {
    assign(bands[bi], opts2);
  }
  function addBand(opts2, bi) {
    opts2.fill = fnOrSelf(opts2.fill || null);
    opts2.dir = ifNull(opts2.dir, -1);
    bi = bi == null ? bands.length : bi;
    bands.splice(bi, 0, opts2);
  }
  function delBand(bi) {
    if (bi == null)
      bands.length = 0;
    else
      bands.splice(bi, 1);
  }
  self.addBand = addBand;
  self.setBand = setBand;
  self.delBand = delBand;
  function setAlpha(i, value) {
    series[i].alpha = value;
    if (showCursor && cursorPts[i] != null)
      cursorPts[i].style.opacity = value;
    if (showLegend && legendRows[i])
      legendRows[i].style.opacity = value;
  }
  let closestDist;
  let closestSeries;
  let focusedSeries;
  const FOCUS_TRUE = { focus: true };
  function setFocus(i) {
    if (i != focusedSeries) {
      let allFocused = i == null;
      let _setAlpha = focus.alpha != 1;
      series.forEach((s, i2) => {
        if (mode == 1 || i2 > 0) {
          let isFocused = allFocused || i2 == 0 || i2 == i;
          s._focus = allFocused ? null : isFocused;
          _setAlpha && setAlpha(i2, isFocused ? 1 : focus.alpha);
        }
      });
      focusedSeries = i;
      _setAlpha && commit();
    }
  }
  if (showLegend && cursorFocus) {
    onMouse(mouseleave, legendTable, (e) => {
      if (cursor._lock)
        return;
      setCursorEvent(e);
      if (focusedSeries != null)
        setSeries(null, FOCUS_TRUE, true, syncOpts.setSeries);
    });
  }
  function posToVal(pos, scale, can2) {
    let sc = scales[scale];
    if (can2)
      pos = pos / pxRatio - (sc.ori == 1 ? plotTopCss : plotLftCss);
    let dim = plotWidCss;
    if (sc.ori == 1) {
      dim = plotHgtCss;
      pos = dim - pos;
    }
    if (sc.dir == -1)
      pos = dim - pos;
    let _min = sc._min, _max = sc._max, pct = pos / dim;
    let sv = _min + (_max - _min) * pct;
    let distr = sc.distr;
    return distr == 3 ? pow(10, sv) : distr == 4 ? sinh(sv, sc.asinh) : distr == 100 ? sc.bwd(sv) : sv;
  }
  function closestIdxFromXpos(pos, can2) {
    let v = posToVal(pos, xScaleKey, can2);
    return closestIdx(v, data[0], i0, i1);
  }
  self.valToIdx = (val) => closestIdx(val, data[0]);
  self.posToIdx = closestIdxFromXpos;
  self.posToVal = posToVal;
  self.valToPos = (val, scale, can2) => scales[scale].ori == 0 ? getHPos(
    val,
    scales[scale],
    can2 ? plotWid : plotWidCss,
    can2 ? plotLft : 0
  ) : getVPos(
    val,
    scales[scale],
    can2 ? plotHgt : plotHgtCss,
    can2 ? plotTop : 0
  );
  self.setCursor = (opts2, _fire, _pub) => {
    mouseLeft1 = opts2.left;
    mouseTop1 = opts2.top;
    updateCursor(null, _fire, _pub);
  };
  function setSelH(off2, dim) {
    setStylePx(selectDiv, LEFT, select.left = off2);
    setStylePx(selectDiv, WIDTH, select.width = dim);
  }
  function setSelV(off2, dim) {
    setStylePx(selectDiv, TOP, select.top = off2);
    setStylePx(selectDiv, HEIGHT, select.height = dim);
  }
  let setSelX = scaleX.ori == 0 ? setSelH : setSelV;
  let setSelY = scaleX.ori == 1 ? setSelH : setSelV;
  function syncLegend() {
    if (showLegend && legend.live) {
      for (let i = mode == 2 ? 1 : 0; i < series.length; i++) {
        if (i == 0 && multiValLegend)
          continue;
        let vals = legend.values[i];
        let j = 0;
        for (let k in vals)
          legendCells[i][j++].firstChild.nodeValue = vals[k];
      }
    }
  }
  function setLegend(opts2, _fire) {
    if (opts2 != null) {
      if (opts2.idxs) {
        opts2.idxs.forEach((didx, sidx) => {
          activeIdxs[sidx] = didx;
        });
      } else if (!isUndef(opts2.idx))
        activeIdxs.fill(opts2.idx);
      legend.idx = activeIdxs[0];
    }
    if (showLegend && legend.live) {
      for (let sidx = 0; sidx < series.length; sidx++) {
        if (sidx > 0 || mode == 1 && !multiValLegend)
          setLegendValues(sidx, activeIdxs[sidx]);
      }
      syncLegend();
    }
    shouldSetLegend = false;
    _fire !== false && fire("setLegend");
  }
  self.setLegend = setLegend;
  function setLegendValues(sidx, idx) {
    let s = series[sidx];
    let src = sidx == 0 && xScaleDistr == 2 ? data0 : data[sidx];
    let val;
    if (multiValLegend)
      val = s.values(self, sidx, idx) ?? NULL_LEGEND_VALUES;
    else {
      val = s.value(self, idx == null ? null : src[idx], sidx, idx);
      val = val == null ? NULL_LEGEND_VALUES : { _: val };
    }
    legend.values[sidx] = val;
  }
  function updateCursor(src, _fire, _pub) {
    rawMouseLeft1 = mouseLeft1;
    rawMouseTop1 = mouseTop1;
    [mouseLeft1, mouseTop1] = cursor.move(self, mouseLeft1, mouseTop1);
    cursor.left = mouseLeft1;
    cursor.top = mouseTop1;
    if (showCursor) {
      vCursor && elTrans(vCursor, round2(mouseLeft1), 0, plotWidCss, plotHgtCss);
      hCursor && elTrans(hCursor, 0, round2(mouseTop1), plotWidCss, plotHgtCss);
    }
    let idx;
    let noDataInRange = i0 > i1;
    closestDist = inf;
    closestSeries = null;
    let xDim = scaleX.ori == 0 ? plotWidCss : plotHgtCss;
    let yDim = scaleX.ori == 1 ? plotWidCss : plotHgtCss;
    if (mouseLeft1 < 0 || dataLen == 0 || noDataInRange) {
      idx = cursor.idx = null;
      for (let i = 0; i < series.length; i++) {
        let pt = cursorPts[i];
        pt != null && elTrans(pt, -10, -10, plotWidCss, plotHgtCss);
      }
      if (cursorFocus)
        setSeries(null, FOCUS_TRUE, true, src == null && syncOpts.setSeries);
      if (legend.live) {
        activeIdxs.fill(idx);
        shouldSetLegend = true;
      }
    } else {
      let mouseXPos, valAtPosX, xPos;
      if (mode == 1) {
        mouseXPos = scaleX.ori == 0 ? mouseLeft1 : mouseTop1;
        valAtPosX = posToVal(mouseXPos, xScaleKey);
        idx = cursor.idx = closestIdx(valAtPosX, data[0], i0, i1);
        xPos = valToPosX(data[0][idx], scaleX, xDim, 0);
      }
      let _ptLft = -10;
      let _ptTop = -10;
      let _ptWid = 0;
      let _ptHgt = 0;
      let _centered = true;
      let _ptFill = "";
      let _ptStroke = "";
      for (let i = mode == 2 ? 1 : 0; i < series.length; i++) {
        let s = series[i];
        let idx1 = activeIdxs[i];
        let yVal1 = idx1 == null ? null : mode == 1 ? data[i][idx1] : data[i][1][idx1];
        let idx2 = cursor.dataIdx(self, i, idx, valAtPosX);
        let yVal2 = idx2 == null ? null : mode == 1 ? data[i][idx2] : data[i][1][idx2];
        shouldSetLegend = shouldSetLegend || yVal2 != yVal1 || idx2 != idx1;
        activeIdxs[i] = idx2;
        if (i > 0 && s.show) {
          let xPos2 = idx2 == null ? -10 : idx2 == idx ? xPos : valToPosX(mode == 1 ? data[0][idx2] : data[i][0][idx2], scaleX, xDim, 0);
          let yPos = yVal2 == null ? -10 : valToPosY(yVal2, mode == 1 ? scales[s.scale] : scales[s.facets[1].scale], yDim, 0);
          if (cursorFocus && yVal2 != null) {
            let mouseYPos = scaleX.ori == 1 ? mouseLeft1 : mouseTop1;
            let dist = abs(focus.dist(self, i, idx2, yPos, mouseYPos));
            if (dist < closestDist) {
              let bias = focus.bias;
              if (bias != 0) {
                let mouseYVal = posToVal(mouseYPos, s.scale);
                let seriesYValSign = yVal2 >= 0 ? 1 : -1;
                let mouseYValSign = mouseYVal >= 0 ? 1 : -1;
                if (mouseYValSign == seriesYValSign && (mouseYValSign == 1 ? bias == 1 ? yVal2 >= mouseYVal : yVal2 <= mouseYVal : (
                  // >= 0
                  bias == 1 ? yVal2 <= mouseYVal : yVal2 >= mouseYVal
                ))) {
                  closestDist = dist;
                  closestSeries = i;
                }
              } else {
                closestDist = dist;
                closestSeries = i;
              }
            }
          }
          if (shouldSetLegend || cursorOnePt) {
            let hPos, vPos;
            if (scaleX.ori == 0) {
              hPos = xPos2;
              vPos = yPos;
            } else {
              hPos = yPos;
              vPos = xPos2;
            }
            let ptWid, ptHgt, ptLft, ptTop, ptStroke, ptFill, centered = true, getBBox = points2.bbox;
            if (getBBox != null) {
              centered = false;
              let bbox = getBBox(self, i);
              ptLft = bbox.left;
              ptTop = bbox.top;
              ptWid = bbox.width;
              ptHgt = bbox.height;
            } else {
              ptLft = hPos;
              ptTop = vPos;
              ptWid = ptHgt = points2.size(self, i);
            }
            ptFill = points2.fill(self, i);
            ptStroke = points2.stroke(self, i);
            if (cursorOnePt) {
              if (i == closestSeries && closestDist <= focus.prox) {
                _ptLft = ptLft;
                _ptTop = ptTop;
                _ptWid = ptWid;
                _ptHgt = ptHgt;
                _centered = centered;
                _ptFill = ptFill;
                _ptStroke = ptStroke;
              }
            } else {
              let pt = cursorPts[i];
              if (pt != null) {
                cursorPtsLft[i] = ptLft;
                cursorPtsTop[i] = ptTop;
                elSize(pt, ptWid, ptHgt, centered);
                elColor(pt, ptFill, ptStroke);
                elTrans(pt, ceil(ptLft), ceil(ptTop), plotWidCss, plotHgtCss);
              }
            }
          }
        }
      }
      if (cursorOnePt) {
        let p = focus.prox;
        let focusChanged = focusedSeries == null ? closestDist <= p : closestDist > p || closestSeries != focusedSeries;
        if (shouldSetLegend || focusChanged) {
          let pt = cursorPts[0];
          if (pt != null) {
            cursorPtsLft[0] = _ptLft;
            cursorPtsTop[0] = _ptTop;
            elSize(pt, _ptWid, _ptHgt, _centered);
            elColor(pt, _ptFill, _ptStroke);
            elTrans(pt, ceil(_ptLft), ceil(_ptTop), plotWidCss, plotHgtCss);
          }
        }
      }
    }
    if (select.show && dragging) {
      if (src != null) {
        let [xKey, yKey] = syncOpts.scales;
        let [matchXKeys, matchYKeys] = syncOpts.match;
        let [xKeySrc, yKeySrc] = src.cursor.sync.scales;
        let sdrag = src.cursor.drag;
        dragX = sdrag._x;
        dragY = sdrag._y;
        if (dragX || dragY) {
          let { left, top, width, height } = src.select;
          let sori = src.scales[xKeySrc].ori;
          let sPosToVal = src.posToVal;
          let sOff, sDim, sc, a, b;
          let matchingX = xKey != null && matchXKeys(xKey, xKeySrc);
          let matchingY = yKey != null && matchYKeys(yKey, yKeySrc);
          if (matchingX && dragX) {
            if (sori == 0) {
              sOff = left;
              sDim = width;
            } else {
              sOff = top;
              sDim = height;
            }
            sc = scales[xKey];
            a = valToPosX(sPosToVal(sOff, xKeySrc), sc, xDim, 0);
            b = valToPosX(sPosToVal(sOff + sDim, xKeySrc), sc, xDim, 0);
            setSelX(min2(a, b), abs(b - a));
          } else
            setSelX(0, xDim);
          if (matchingY && dragY) {
            if (sori == 1) {
              sOff = left;
              sDim = width;
            } else {
              sOff = top;
              sDim = height;
            }
            sc = scales[yKey];
            a = valToPosY(sPosToVal(sOff, yKeySrc), sc, yDim, 0);
            b = valToPosY(sPosToVal(sOff + sDim, yKeySrc), sc, yDim, 0);
            setSelY(min2(a, b), abs(b - a));
          } else
            setSelY(0, yDim);
        } else
          hideSelect();
      } else {
        let rawDX = abs(rawMouseLeft1 - rawMouseLeft0);
        let rawDY = abs(rawMouseTop1 - rawMouseTop0);
        if (scaleX.ori == 1) {
          let _rawDX = rawDX;
          rawDX = rawDY;
          rawDY = _rawDX;
        }
        dragX = drag.x && rawDX >= drag.dist;
        dragY = drag.y && rawDY >= drag.dist;
        let uni = drag.uni;
        if (uni != null) {
          if (dragX && dragY) {
            dragX = rawDX >= uni;
            dragY = rawDY >= uni;
            if (!dragX && !dragY) {
              if (rawDY > rawDX)
                dragY = true;
              else
                dragX = true;
            }
          }
        } else if (drag.x && drag.y && (dragX || dragY))
          dragX = dragY = true;
        let p0, p1;
        if (dragX) {
          if (scaleX.ori == 0) {
            p0 = mouseLeft0;
            p1 = mouseLeft1;
          } else {
            p0 = mouseTop0;
            p1 = mouseTop1;
          }
          setSelX(min2(p0, p1), abs(p1 - p0));
          if (!dragY)
            setSelY(0, yDim);
        }
        if (dragY) {
          if (scaleX.ori == 1) {
            p0 = mouseLeft0;
            p1 = mouseLeft1;
          } else {
            p0 = mouseTop0;
            p1 = mouseTop1;
          }
          setSelY(min2(p0, p1), abs(p1 - p0));
          if (!dragX)
            setSelX(0, xDim);
        }
        if (!dragX && !dragY) {
          setSelX(0, 0);
          setSelY(0, 0);
        }
      }
    }
    drag._x = dragX;
    drag._y = dragY;
    if (src == null) {
      if (_pub) {
        if (syncKey != null) {
          let [xSyncKey, ySyncKey] = syncOpts.scales;
          syncOpts.values[0] = xSyncKey != null ? posToVal(scaleX.ori == 0 ? mouseLeft1 : mouseTop1, xSyncKey) : null;
          syncOpts.values[1] = ySyncKey != null ? posToVal(scaleX.ori == 1 ? mouseLeft1 : mouseTop1, ySyncKey) : null;
        }
        pubSync(mousemove, self, mouseLeft1, mouseTop1, plotWidCss, plotHgtCss, idx);
      }
      if (cursorFocus) {
        let shouldPub = _pub && syncOpts.setSeries;
        let p = focus.prox;
        if (focusedSeries == null) {
          if (closestDist <= p)
            setSeries(closestSeries, FOCUS_TRUE, true, shouldPub);
        } else {
          if (closestDist > p)
            setSeries(null, FOCUS_TRUE, true, shouldPub);
          else if (closestSeries != focusedSeries)
            setSeries(closestSeries, FOCUS_TRUE, true, shouldPub);
        }
      }
    }
    if (shouldSetLegend) {
      legend.idx = idx;
      setLegend();
    }
    _fire !== false && fire("setCursor");
  }
  let rect2 = null;
  Object.defineProperty(self, "rect", {
    get() {
      if (rect2 == null)
        syncRect(false);
      return rect2;
    }
  });
  function syncRect(defer = false) {
    if (defer)
      rect2 = null;
    else {
      rect2 = over.getBoundingClientRect();
      fire("syncRect", rect2);
    }
  }
  function mouseMove(e, src, _l, _t, _w, _h, _i) {
    if (cursor._lock)
      return;
    if (dragging && e != null && e.movementX == 0 && e.movementY == 0)
      return;
    cacheMouse(e, src, _l, _t, _w, _h, _i, false, e != null);
    if (e != null)
      updateCursor(null, true, true);
    else
      updateCursor(src, true, false);
  }
  function cacheMouse(e, src, _l, _t, _w, _h, _i, initial, snap) {
    if (rect2 == null)
      syncRect(false);
    setCursorEvent(e);
    if (e != null) {
      _l = e.clientX - rect2.left;
      _t = e.clientY - rect2.top;
    } else {
      if (_l < 0 || _t < 0) {
        mouseLeft1 = -10;
        mouseTop1 = -10;
        return;
      }
      let [xKey, yKey] = syncOpts.scales;
      let syncOptsSrc = src.cursor.sync;
      let [xValSrc, yValSrc] = syncOptsSrc.values;
      let [xKeySrc, yKeySrc] = syncOptsSrc.scales;
      let [matchXKeys, matchYKeys] = syncOpts.match;
      let rotSrc = src.axes[0].side % 2 == 1;
      let xDim = scaleX.ori == 0 ? plotWidCss : plotHgtCss, yDim = scaleX.ori == 1 ? plotWidCss : plotHgtCss, _xDim = rotSrc ? _h : _w, _yDim = rotSrc ? _w : _h, _xPos = rotSrc ? _t : _l, _yPos = rotSrc ? _l : _t;
      if (xKeySrc != null)
        _l = matchXKeys(xKey, xKeySrc) ? getPos(xValSrc, scales[xKey], xDim, 0) : -10;
      else
        _l = xDim * (_xPos / _xDim);
      if (yKeySrc != null)
        _t = matchYKeys(yKey, yKeySrc) ? getPos(yValSrc, scales[yKey], yDim, 0) : -10;
      else
        _t = yDim * (_yPos / _yDim);
      if (scaleX.ori == 1) {
        let __l = _l;
        _l = _t;
        _t = __l;
      }
    }
    if (snap && (src == null || src.cursor.event.type == mousemove)) {
      if (_l <= 1 || _l >= plotWidCss - 1)
        _l = incrRound(_l, plotWidCss);
      if (_t <= 1 || _t >= plotHgtCss - 1)
        _t = incrRound(_t, plotHgtCss);
    }
    if (initial) {
      rawMouseLeft0 = _l;
      rawMouseTop0 = _t;
      [mouseLeft0, mouseTop0] = cursor.move(self, _l, _t);
    } else {
      mouseLeft1 = _l;
      mouseTop1 = _t;
    }
  }
  const _hideProps = {
    width: 0,
    height: 0,
    left: 0,
    top: 0
  };
  function hideSelect() {
    setSelect(_hideProps, false);
  }
  let downSelectLeft;
  let downSelectTop;
  let downSelectWidth;
  let downSelectHeight;
  function mouseDown(e, src, _l, _t, _w, _h, _i) {
    dragging = true;
    dragX = dragY = drag._x = drag._y = false;
    cacheMouse(e, src, _l, _t, _w, _h, _i, true, false);
    if (e != null) {
      onMouse(mouseup, doc, mouseUp, false);
      pubSync(mousedown, self, mouseLeft0, mouseTop0, plotWidCss, plotHgtCss, null);
    }
    let { left, top, width, height } = select;
    downSelectLeft = left;
    downSelectTop = top;
    downSelectWidth = width;
    downSelectHeight = height;
  }
  function mouseUp(e, src, _l, _t, _w, _h, _i) {
    dragging = drag._x = drag._y = false;
    cacheMouse(e, src, _l, _t, _w, _h, _i, false, true);
    let { left, top, width, height } = select;
    let hasSelect = width > 0 || height > 0;
    let chgSelect = downSelectLeft != left || downSelectTop != top || downSelectWidth != width || downSelectHeight != height;
    hasSelect && chgSelect && setSelect(select);
    if (drag.setScale && hasSelect && chgSelect) {
      let xOff = left, xDim = width, yOff = top, yDim = height;
      if (scaleX.ori == 1) {
        xOff = top, xDim = height, yOff = left, yDim = width;
      }
      if (dragX) {
        _setScale(
          xScaleKey,
          posToVal(xOff, xScaleKey),
          posToVal(xOff + xDim, xScaleKey)
        );
      }
      if (dragY) {
        for (let k in scales) {
          let sc = scales[k];
          if (k != xScaleKey && sc.from == null && sc.min != inf) {
            _setScale(
              k,
              posToVal(yOff + yDim, k),
              posToVal(yOff, k)
            );
          }
        }
      }
      hideSelect();
    } else if (cursor.lock) {
      cursor._lock = !cursor._lock;
      updateCursor(src, true, e != null);
    }
    if (e != null) {
      offMouse(mouseup, doc);
      pubSync(mouseup, self, mouseLeft1, mouseTop1, plotWidCss, plotHgtCss, null);
    }
  }
  function mouseLeave(e, src, _l, _t, _w, _h, _i) {
    if (cursor._lock)
      return;
    setCursorEvent(e);
    let _dragging = dragging;
    if (dragging) {
      let snapH = true;
      let snapV = true;
      let snapProx = 10;
      let dragH, dragV;
      if (scaleX.ori == 0) {
        dragH = dragX;
        dragV = dragY;
      } else {
        dragH = dragY;
        dragV = dragX;
      }
      if (dragH && dragV) {
        snapH = mouseLeft1 <= snapProx || mouseLeft1 >= plotWidCss - snapProx;
        snapV = mouseTop1 <= snapProx || mouseTop1 >= plotHgtCss - snapProx;
      }
      if (dragH && snapH)
        mouseLeft1 = mouseLeft1 < mouseLeft0 ? 0 : plotWidCss;
      if (dragV && snapV)
        mouseTop1 = mouseTop1 < mouseTop0 ? 0 : plotHgtCss;
      updateCursor(null, true, true);
      dragging = false;
    }
    mouseLeft1 = -10;
    mouseTop1 = -10;
    activeIdxs.fill(null);
    updateCursor(null, true, true);
    if (_dragging)
      dragging = _dragging;
  }
  function dblClick(e, src, _l, _t, _w, _h, _i) {
    if (cursor._lock)
      return;
    setCursorEvent(e);
    autoScaleX();
    hideSelect();
    if (e != null)
      pubSync(dblclick, self, mouseLeft1, mouseTop1, plotWidCss, plotHgtCss, null);
  }
  function syncPxRatio() {
    axes.forEach(syncFontSize);
    _setSize(self.width, self.height, true);
  }
  on(dppxchange, win, syncPxRatio);
  const events = {};
  events.mousedown = mouseDown;
  events.mousemove = mouseMove;
  events.mouseup = mouseUp;
  events.dblclick = dblClick;
  events["setSeries"] = (e, src, idx, opts2) => {
    let seriesIdxMatcher2 = syncOpts.match[2];
    idx = seriesIdxMatcher2(self, src, idx);
    idx != -1 && setSeries(idx, opts2, true, false);
  };
  if (showCursor) {
    onMouse(mousedown, over, mouseDown);
    onMouse(mousemove, over, mouseMove);
    onMouse(mouseenter, over, (e) => {
      setCursorEvent(e);
      syncRect(false);
    });
    onMouse(mouseleave, over, mouseLeave);
    onMouse(dblclick, over, dblClick);
    cursorPlots.add(self);
    self.syncRect = syncRect;
  }
  const hooks = self.hooks = opts.hooks || {};
  function fire(evName, a1, a2) {
    if (deferHooks)
      hooksQueue.push([evName, a1, a2]);
    else {
      if (evName in hooks) {
        hooks[evName].forEach((fn) => {
          fn.call(null, self, a1, a2);
        });
      }
    }
  }
  (opts.plugins || []).forEach((p) => {
    for (let evName in p.hooks)
      hooks[evName] = (hooks[evName] || []).concat(p.hooks[evName]);
  });
  const seriesIdxMatcher = (self2, src, srcSeriesIdx) => srcSeriesIdx;
  const syncOpts = assign({
    key: null,
    setSeries: false,
    filters: {
      pub: retTrue,
      sub: retTrue
    },
    scales: [xScaleKey, series[1] ? series[1].scale : null],
    match: [retEq, retEq, seriesIdxMatcher],
    values: [null, null]
  }, cursor.sync);
  if (syncOpts.match.length == 2)
    syncOpts.match.push(seriesIdxMatcher);
  cursor.sync = syncOpts;
  const syncKey = syncOpts.key;
  const sync = _sync(syncKey);
  function pubSync(type, src, x, y, w, h, i) {
    if (syncOpts.filters.pub(type, src, x, y, w, h, i))
      sync.pub(type, src, x, y, w, h, i);
  }
  sync.sub(self);
  function pub(type, src, x, y, w, h, i) {
    if (syncOpts.filters.sub(type, src, x, y, w, h, i))
      events[type](null, src, x, y, w, h, i);
  }
  self.pub = pub;
  function destroy() {
    sync.unsub(self);
    cursorPlots.delete(self);
    mouseListeners.clear();
    off(dppxchange, win, syncPxRatio);
    root.remove();
    legendTable?.remove();
    fire("destroy");
  }
  self.destroy = destroy;
  function _init() {
    fire("init", opts, data);
    setData(data || opts.data, false);
    if (pendScales[xScaleKey])
      setScale(xScaleKey, pendScales[xScaleKey]);
    else
      autoScaleX();
    shouldSetSelect = select.show && (select.width > 0 || select.height > 0);
    shouldSetCursor = shouldSetLegend = true;
    _setSize(opts.width, opts.height);
  }
  series.forEach(initSeries);
  axes.forEach(initAxis);
  if (then) {
    if (then instanceof HTMLElement) {
      then.appendChild(root);
      _init();
    } else
      then(self, _init);
  } else
    _init();
  return self;
}
uPlot.assign = assign;
uPlot.fmtNum = fmtNum;
uPlot.rangeNum = rangeNum;
uPlot.rangeLog = rangeLog;
uPlot.rangeAsinh = rangeAsinh;
uPlot.orient = orient;
uPlot.pxRatio = pxRatio;
{
  uPlot.join = join;
}
{
  uPlot.fmtDate = fmtDate;
  uPlot.tzDate = tzDate;
}
uPlot.sync = _sync;
{
  uPlot.addGap = addGap;
  uPlot.clipGaps = clipGaps;
  let paths = uPlot.paths = {
    points
  };
  paths.linear = linear;
  paths.stepped = stepped;
  paths.bars = bars;
  paths.spline = monotoneCubic;
}

// js/chart_hook.js
var DEFAULT_HEIGHT = 320;
var DEFAULT_PALETTE = [
  "--chart-1",
  "--chart-2",
  "--chart-3",
  "--chart-4",
  "--chart-5"
];
var DEFAULT_BAR_SIZE = [0.72, 64];
var SERIES_META_KEYS = /* @__PURE__ */ new Set([
  "color",
  "curve",
  "data",
  "format",
  "name",
  "prefix",
  "precision",
  "suffix",
  "value_format"
]);
function isPlainObject(value) {
  return value != null && typeof value === "object" && !Array.isArray(value);
}
function mergeDeep(...values) {
  return values.reduce((acc, value) => mergePair(acc, value), {});
}
function mergePair(left, right) {
  if (!isPlainObject(left)) {
    return cloneValue(right);
  }
  if (!isPlainObject(right)) {
    return cloneValue(right == null ? left : right);
  }
  const merged = { ...left };
  Object.entries(right).forEach(([key, value]) => {
    if (isPlainObject(value) && isPlainObject(merged[key])) {
      merged[key] = mergePair(merged[key], value);
      return;
    }
    merged[key] = cloneValue(value);
  });
  return merged;
}
function cloneValue(value) {
  if (Array.isArray(value)) {
    return value.map((entry) => cloneValue(entry));
  }
  if (isPlainObject(value)) {
    return Object.fromEntries(
      Object.entries(value).map(([key, entry]) => [key, cloneValue(entry)])
    );
  }
  return value;
}
function stripSeriesMeta(series) {
  return Object.fromEntries(
    Object.entries(series || {}).filter(([key]) => !SERIES_META_KEYS.has(key))
  );
}
function toArray(value) {
  return Array.isArray(value) ? value : [];
}
function toSecondsTimestamp(value) {
  if (typeof value !== "number") {
    return value;
  }
  return value > 1e12 ? value : value * 1e3;
}
var ChartHook = class extends ViewHook8 {
  uPlot = uPlot;
  chart = null;
  data = [];
  opts = {};
  payload = {};
  colorResolutionCache = /* @__PURE__ */ new Map();
  root = null;
  tooltip = null;
  resizeObserver = null;
  size = { width: 0, height: 0 };
  structureSignature = null;
  dataSignature = null;
  mounted() {
    this.cacheElements();
    this.connectResizeObserver();
    this.renderChart(true);
  }
  updated() {
    this.cacheElements();
    this.renderChart();
  }
  destroyed() {
    this.hideTooltip();
    this.resizeObserver?.disconnect();
    this.resizeObserver = null;
    this.destroyChart();
  }
  cacheElements() {
    this.root = this.el.querySelector("[data-chart-root]");
    this.tooltip = this.el.querySelector("[data-chart-tooltip]");
  }
  connectResizeObserver() {
    this.resizeObserver?.disconnect();
    if (!this.root) {
      return;
    }
    this.resizeObserver = new ResizeObserver(() => {
      if (!this.chart) {
        return;
      }
      const nextSize = this.measureSize(this.payload);
      if (nextSize.width === this.size.width && nextSize.height === this.size.height) {
        return;
      }
      this.size = nextSize;
      this.chart.setSize(nextSize);
      this.updateTooltipPosition(this.chart);
    });
    this.resizeObserver.observe(this.root);
  }
  readPayload() {
    try {
      return JSON.parse(this.el.dataset.chartConfig || "{}");
    } catch (_error) {
      return {};
    }
  }
  inferPreset(rawPayload) {
    if (rawPayload?.preset) {
      return rawPayload.preset;
    }
    const inferred = this.constructor.name.replace(/Hook$/, "").replace(/Chart$/, "").toLowerCase();
    return inferred === "chart" ? null : inferred;
  }
  normalizePayload(rawPayload) {
    const payload = rawPayload || {};
    return {
      ...payload,
      preset: this.inferPreset(payload),
      data: toArray(payload.data),
      series: toArray(payload.series),
      options: isPlainObject(payload.options) ? payload.options : {},
      tooltip: mergeDeep({ show: true }, payload.tooltip || {}),
      legend: mergeDeep({ show: false }, payload.legend || {}),
      grid: payload.grid !== false,
      height: payload.height || DEFAULT_HEIGHT
    };
  }
  measureSize(payload) {
    const width = Math.max(
      Math.round(this.root?.clientWidth || this.el.clientWidth || 0),
      240
    );
    return {
      width,
      height: payload.height || DEFAULT_HEIGHT
    };
  }
  renderChart(force = false) {
    if (!this.root) {
      return;
    }
    const payload = this.normalizePayload(this.readPayload());
    const size3 = this.measureSize(payload);
    const structureSignature = JSON.stringify({
      ...payload,
      data: void 0,
      width: size3.width,
      height: size3.height
    });
    const dataSignature = JSON.stringify(payload.data);
    this.payload = payload;
    this.size = size3;
    if (!this.chart || force || structureSignature !== this.structureSignature) {
      this.rebuildChart(payload, size3);
      this.structureSignature = structureSignature;
      this.dataSignature = dataSignature;
      return;
    }
    const nextData = this.buildData(payload);
    const nextOpts = this.buildOptions(payload, size3);
    this.data = nextData;
    this.opts = nextOpts;
    if (dataSignature !== this.dataSignature) {
      this.chart.setData(nextData, payload.reset_scales !== false);
      this.dataSignature = dataSignature;
    }
    if (size3.width !== this.chart.width || size3.height !== this.chart.height) {
      this.chart.setSize(size3);
    }
  }
  rebuildChart(payload, size3) {
    this.destroyChart();
    this.data = this.buildData(payload);
    this.opts = this.buildOptions(payload, size3);
    this.chart = new this.uPlot(this.opts, this.data, this.root);
    this.hideTooltip();
  }
  destroyChart() {
    if (!this.chart) {
      return;
    }
    this.chart.destroy();
    this.chart = null;
  }
  buildData(payload) {
    return toArray(payload.data);
  }
  buildOptions(payload, size3) {
    const preset = payload.preset;
    const defaults = {
      width: size3.width,
      height: size3.height,
      padding: [10, 8, 6, 0],
      focus: { alpha: 0.3 },
      legend: {
        show: payload.legend?.show === true,
        live: payload.legend?.live ?? true
      },
      cursor: {
        y: false,
        x: true,
        focus: { prox: 24 },
        points: { show: false }
      },
      select: { show: false },
      axes: this.buildAxes(payload),
      scales: this.buildScales(payload),
      series: [{}, ...this.buildSeries(payload, preset)]
    };
    const options = mergeDeep(defaults, payload.options);
    options.width = size3.width;
    options.height = size3.height;
    options.hooks = this.mergeHooks(options.hooks, this.buildHooks(payload));
    return this.resolveColors(options);
  }
  buildScales(payload) {
    const xLength = toArray(payload.data[0]).length;
    if (payload.preset === "bar") {
      return {
        x: { time: false, range: [-0.5, Math.max(xLength - 0.5, 0.5)] },
        y: { auto: true }
      };
    }
    if (payload.time) {
      return {
        x: { time: true },
        y: { auto: true }
      };
    }
    return {
      x: { time: false },
      y: { auto: true }
    };
  }
  buildAxes(payload) {
    const font2 = this.axisFont();
    const axisColor = this.resolveCssValue("var(--chart-axis-color)");
    const gridColor = this.resolveCssValue("var(--chart-grid-color)");
    const baseX = {
      ticks: { show: false },
      border: { show: false },
      grid: { show: false },
      gap: 6,
      size: 28,
      font: font2,
      stroke: axisColor
    };
    const baseY = {
      ticks: { show: false },
      border: { show: false },
      grid: { show: payload.grid, stroke: gridColor, width: 0.5 },
      gap: 6,
      size: 52,
      font: font2,
      stroke: axisColor,
      values: (_self, values) => values.map((value) => this.formatNumericValue(value, payload.y_axis))
    };
    if (payload.time) {
      return [baseX, baseY];
    }
    if (Array.isArray(payload.categories) && payload.categories.length > 0) {
      return [
        {
          ...baseX,
          values: (_self, values) => values.map((value) => this.lookupLabel(payload.categories, value))
        },
        baseY
      ];
    }
    if (Array.isArray(payload.labels) && payload.labels.length > 0) {
      return [
        {
          ...baseX,
          values: (_self, values) => values.map((value) => this.lookupLabel(payload.labels, value))
        },
        baseY
      ];
    }
    return [baseX, baseY];
  }
  buildSeries(payload, preset) {
    return payload.series.map((series, index) => {
      const stroke = this.resolveCssValue(
        series.color || series.stroke || this.paletteColor(index)
      );
      const shared = {
        label: series.label || series.name || `Series ${index + 1}`,
        stroke,
        width: series.width ?? (preset === "bar" ? 0 : 2),
        points: mergeDeep({ show: false }, series.points || {})
      };
      const nextSeries = mergeDeep(shared, stripSeriesMeta(series));
      if (preset === "bar") {
        nextSeries.fill = this.resolveCssValue(series.fill || stroke);
        nextSeries.paths = this.uPlot.paths.bars({
          size: payload.bar?.size || DEFAULT_BAR_SIZE
        });
      }
      if (preset === "line") {
        if (payload.area || series.area) {
          nextSeries.fill = this.resolveCssValue(
            series.fill || this.withAlpha(stroke, 0.18)
          );
        }
        nextSeries.paths = this.resolveLinePath(series, payload);
      }
      return nextSeries;
    });
  }
  resolveLinePath(series, payload) {
    const curve = series.curve || payload.curve || "linear";
    switch (curve) {
      case "stepped":
        return this.uPlot.paths.stepped({ align: 1 });
      case "spline":
        return this.uPlot.paths.spline();
      default:
        return this.uPlot.paths.linear();
    }
  }
  buildHooks(payload) {
    return {
      setCursor: [
        (chart) => {
          if (!payload.tooltip?.show) {
            return;
          }
          this.updateTooltipPosition(chart);
        }
      ],
      setSeries: [
        () => {
          this.hideTooltip();
        }
      ],
      destroy: [
        () => {
          this.hideTooltip();
        }
      ]
    };
  }
  mergeHooks(existingHooks = {}, additionalHooks = {}) {
    const keys = /* @__PURE__ */ new Set([
      ...Object.keys(existingHooks || {}),
      ...Object.keys(additionalHooks || {})
    ]);
    return Array.from(keys).reduce((hooks, key) => {
      hooks[key] = [
        ...toArray(existingHooks?.[key]),
        ...toArray(additionalHooks?.[key])
      ];
      return hooks;
    }, {});
  }
  updateTooltipPosition(chart) {
    if (!this.tooltip) {
      return;
    }
    const idx = chart?.cursor?.idx;
    const left = chart?.cursor?.left;
    const top = chart?.cursor?.top;
    if (idx == null || left == null || top == null || left < 0 || top < 0) {
      this.hideTooltip();
      return;
    }
    const rows = this.tooltipRows(chart, idx);
    if (rows.length === 0) {
      this.hideTooltip();
      return;
    }
    this.renderTooltipContent(chart, idx, rows);
    const rect2 = chart.over.getBoundingClientRect();
    const x = rect2.left + left;
    const y = rect2.top + top;
    const virtualElement = {
      getBoundingClientRect: () => new DOMRect(x, y, 0, 0)
    };
    this.tooltip.classList.remove("hidden");
    computePosition2(virtualElement, this.tooltip, {
      strategy: "fixed",
      placement: "top-start",
      middleware: [offset2(14), flip2(), shift2({ padding: 12 })]
    }).then(({ x: tooltipX, y: tooltipY }) => {
      Object.assign(this.tooltip.style, {
        left: `${tooltipX}px`,
        top: `${tooltipY}px`
      });
    });
  }
  tooltipRows(chart, idx) {
    return chart.series.slice(1).map((series, offset3) => {
      const value = chart.data[offset3 + 1]?.[idx];
      if (value == null || series.show === false) {
        return null;
      }
      const config = this.payload.series[offset3] || {};
      return {
        label: series.label,
        color: series.stroke,
        value: this.formatSeriesValue(value, config)
      };
    }).filter(Boolean);
  }
  renderTooltipContent(chart, idx, rows) {
    if (!this.tooltip) {
      return;
    }
    const title = document.createElement("div");
    title.className = "pui-chart-tooltip__title";
    title.textContent = this.tooltipTitle(chart, idx);
    const list = document.createElement("div");
    list.className = "pui-chart-tooltip__list";
    rows.forEach((row) => {
      const item = document.createElement("div");
      item.className = "pui-chart-tooltip__row";
      const label = document.createElement("div");
      label.className = "pui-chart-tooltip__label";
      const marker = document.createElement("span");
      marker.className = "pui-chart-tooltip__marker";
      marker.style.backgroundColor = row.color;
      const text = document.createElement("span");
      text.textContent = row.label;
      const value = document.createElement("span");
      value.className = "pui-chart-tooltip__value";
      value.textContent = row.value;
      label.append(marker, text);
      item.append(label, value);
      list.append(item);
    });
    this.tooltip.replaceChildren(title, list);
  }
  tooltipTitle(chart, idx) {
    const xValue = chart.data[0]?.[idx];
    if (Array.isArray(this.payload.categories) && this.payload.categories[idx] != null) {
      return `${this.payload.categories[idx]}`;
    }
    if (Array.isArray(this.payload.labels) && this.payload.labels[idx] != null) {
      return `${this.payload.labels[idx]}`;
    }
    if (this.payload.time) {
      const formatter = new Intl.DateTimeFormat(void 0, {
        month: "short",
        day: "numeric",
        hour: "2-digit",
        minute: "2-digit"
      });
      return formatter.format(new Date(toSecondsTimestamp(xValue)));
    }
    return `${xValue}`;
  }
  formatSeriesValue(value, series) {
    const number = this.formatNumericValue(value, series);
    const prefix = series.prefix || "";
    const suffix = series.suffix || "";
    return `${prefix}${number}${suffix}`;
  }
  formatNumericValue(value, config = {}) {
    if (typeof value !== "number") {
      return `${value}`;
    }
    if (Number.isInteger(value) && config.precision == null) {
      return new Intl.NumberFormat(void 0).format(value);
    }
    const maximumFractionDigits = config.precision != null ? config.precision : value % 1 === 0 ? 0 : 2;
    return new Intl.NumberFormat(void 0, {
      maximumFractionDigits
    }).format(value);
  }
  lookupLabel(labels, value) {
    const index = Math.round(value);
    return index >= 0 && index < labels.length ? `${labels[index]}` : "";
  }
  hideTooltip() {
    if (!this.tooltip) {
      return;
    }
    this.tooltip.classList.add("hidden");
    this.tooltip.replaceChildren();
  }
  axisFont() {
    const fontFamily = getComputedStyle(this.el).getPropertyValue("--font-sans").trim() || "system-ui, sans-serif";
    return `12px ${fontFamily}`;
  }
  paletteColor(index) {
    return `var(${DEFAULT_PALETTE[index % DEFAULT_PALETTE.length]})`;
  }
  resolveCssValue(value) {
    if (typeof value !== "string") {
      return value;
    }
    const match = value.trim().match(/^var\((--[^)]+)\)$/);
    const resolved = match ? getComputedStyle(this.el).getPropertyValue(match[1]).trim() || value : value;
    return this.resolveCanvasColor(resolved);
  }
  resolveCanvasColor(value) {
    if (!this.isColorLikeValue(value)) {
      return value;
    }
    const trimmed = value.trim();
    const cached = this.colorResolutionCache.get(trimmed);
    if (cached) {
      return cached;
    }
    const probe = document.createElement("span");
    probe.style.color = trimmed;
    probe.style.position = "absolute";
    probe.style.visibility = "hidden";
    probe.style.pointerEvents = "none";
    this.el.appendChild(probe);
    const resolved = getComputedStyle(probe).color || trimmed;
    probe.remove();
    this.colorResolutionCache.set(trimmed, resolved);
    return resolved;
  }
  withAlpha(color, alpha) {
    const resolved = this.resolveCanvasColor(color);
    const match = resolved.match(/^rgba?\(([^)]+)\)$/i);
    if (!match) {
      return resolved;
    }
    const [red, green, blue] = match[1].split(",").slice(0, 3).map((channel) => channel.trim());
    return `rgba(${red}, ${green}, ${blue}, ${alpha})`;
  }
  isColorLikeValue(value) {
    if (typeof value !== "string") {
      return false;
    }
    const trimmed = value.trim();
    return /^#(?:[\da-f]{3,8})$/i.test(trimmed) || /^(?:rgb|rgba|hsl|hsla|hwb|lab|lch|oklab|oklch|color|color-mix)\(/i.test(
      trimmed
    );
  }
  resolveColors(value) {
    if (Array.isArray(value)) {
      return value.map((entry) => this.resolveColors(entry));
    }
    if (isPlainObject(value)) {
      return Object.fromEntries(
        Object.entries(value).map(([key, entry]) => [
          key,
          this.resolveColors(entry)
        ])
      );
    }
    return this.resolveCssValue(value);
  }
};
var chart_hook_default = ChartHook;

// js/bar_chart.js
var BarChart = class extends chart_hook_default {
};

// js/line_chart.js
var LineChart = class extends chart_hook_default {
};

// js/sparkline_chart.js
var SparklineChart = class extends chart_hook_default {
  measureSize(payload) {
    const width = Math.max(
      Math.round(this.root?.clientWidth || this.el.clientWidth || 0),
      48
    );
    return {
      width,
      height: payload.height || 56
    };
  }
  buildOptions(payload, size3) {
    const options = super.buildOptions(
      {
        ...payload,
        preset: "line",
        grid: false,
        tooltip: { ...payload.tooltip, show: false },
        legend: { ...payload.legend, show: false, live: false }
      },
      size3
    );
    return {
      ...options,
      padding: [4, 2, 4, 2],
      cursor: { show: false },
      select: { show: false },
      legend: { show: false },
      axes: [{ show: false }, { show: false }],
      series: options.series.map((series, index) => {
        if (index === 0) {
          return series;
        }
        return {
          ...series,
          width: payload.series[index - 1]?.width ?? 1.5,
          points: { show: false },
          fill: payload.series[index - 1]?.fill || this.withAlpha(series.stroke, 0.18),
          paths: this.uPlot.paths.linear()
        };
      })
    };
  }
};

// js/index.js
var Hooks = {
  "PUI.LoadingBar": LoadingBar,
  "PUI.Popover": Popover,
  "PUI.DatePicker": DatePicker,
  "PUI.Select": Select,
  "PUI.Tabs": Tabs,
  "PUI.Tooltip": Tooltip,
  "PUI.FlashGroup": FlashGroup,
  "PUI.Sidebar": sidebar_default,
  "PUI.Chart": chart_hook_default,
  "PUI.BarChart": BarChart,
  "PUI.LineChart": LineChart,
  "PUI.SparklineChart": SparklineChart
};
export {
  BarChart,
  chart_hook_default as ChartHook,
  DatePicker,
  FlashGroup,
  Hooks,
  LineChart,
  LoadingBar,
  Popover,
  Select,
  sidebar_default as Sidebar,
  SparklineChart,
  Tabs,
  Tooltip
};
//# sourceMappingURL=pui.mjs.map
