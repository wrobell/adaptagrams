#include "libavoid/libavoid.h"
using namespace Avoid;
int main(void) {
    Router *router = new Router(OrthogonalRouting);
    router->setRoutingPenalty((Avoid::PenaltyType)0, 50);
    router->setRoutingPenalty((Avoid::PenaltyType)1, 0);
    router->setRoutingPenalty((Avoid::PenaltyType)2, 200);
    router->setRoutingPenalty((Avoid::PenaltyType)3, 4000);
    router->setRoutingPenalty((Avoid::PenaltyType)4, 110);
    router->setOrthogonalNudgeDistance(25);
    Rectangle rect548374163(Point(51900, 50400), Point(52300, 50900));
    new ShapeRef(router, rect548374163, 548374163);
    Rectangle rect901116812(Point(51131, 49750), Point(51531, 50100));
    new ShapeRef(router, rect901116812, 901116812);
    Rectangle rect335855988(Point(51125, 50175), Point(51525, 50900));
    new ShapeRef(router, rect335855988, 335855988);
    Rectangle rect448725420(Point(52375, 50750), Point(52575, 50900));
    new ShapeRef(router, rect448725420, 448725420);
    Rectangle rect74263573(Point(51900, 49750), Point(52300, 50100));
    new ShapeRef(router, rect74263573, 74263573);
    ConnEnd srcPt463223880(Point(51500, 50275), 8);
    ConnEnd dstPt463223880(Point(51150, 50275), 4);
    ConnEnd srcPt144520410(Point(51150, 49850), 4);
    ConnEnd dstPt144520410(Point(51500, 50350), 8);
    ConnEnd srcPt45398340(Point(52400, 50825), 4);
    ConnEnd dstPt45398340(Point(51500, 49925), 8);
    ConnEnd srcPt29344262(Point(51150, 50500), 4);
    ConnEnd dstPt29344262(Point(51925, 50000), 4);
    new ConnRef(router, srcPt29344262, dstPt29344262, 29344262);
    new ConnRef(router, srcPt45398340, dstPt45398340, 45398340);
    new ConnRef(router, srcPt144520410, dstPt144520410, 144520410);
    new ConnRef(router, srcPt463223880, dstPt463223880, 463223880);
    router->processTransaction();
    router->outputInstanceToSVG("test-nudgeintobug");
    bool overlap = router->existsOrthogonalPathOverlap();
    bool touching = router->existsOrthogonalTouchingPaths();
    delete router;
    return (overlap || touching) ? 1 : 0;
};

