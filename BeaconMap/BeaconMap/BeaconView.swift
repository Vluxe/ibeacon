//
//  BeaconView.swift
//  BeaconMap
//
//  Created by Dalton Cherry on 12/23/16.
//  Copyright © 2016 vluxe. All rights reserved.
//

import AppKit

class BeaconView: View {
    let meterToPixel: CGFloat = 50
    var beacons = [View]()
    var fakeView = View()
    let roomBox = View()
    let roomLength: CGFloat = 7.4168
    let roomWidth: CGFloat = 4.4958
    var radiusViews = [View]()
    let beaconSize: CGFloat = 20
    
    override func setup() {
        super.setup()
        let size: CGFloat = 20
        fakeView.frame = CGRect(x: 10, y: 10, width: size, height: size)
        fakeView.layer?.backgroundColor = NSColor.blue.cgColor
        fakeView.layer?.cornerRadius = size / 2
        addSubview(fakeView)
        
        let roomPoint = CGPoint(x: 80, y: 100)
        roomBox.frame = CGRect(x: roomPoint.x, y: roomPoint.y, width: roomLength * meterToPixel, height: roomWidth * meterToPixel)
        roomBox.layer?.borderWidth = 2
        roomBox.layer?.borderColor = NSColor.black.cgColor
        addSubview(roomBox)
        
        addBeacon(point: CGPoint(x: roomPoint.x + (roomLength * meterToPixel) - beaconSize, y: roomPoint.y + (roomWidth * meterToPixel) - beaconSize))
        addBeacon(point: CGPoint(x: roomPoint.x + ((roomLength * meterToPixel) / 2) - beaconSize, y: roomPoint.y))
        addBeacon(point: CGPoint(x: roomPoint.x, y: roomPoint.y + (roomWidth * meterToPixel) - beaconSize))
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) { [unowned self] in
//            self.updateUser(dist1: self.roomLength / 2, dist2: self.roomWidth - 1, dist3: self.roomLength / 2)
//        }
    }
    
    func addBeacon(point: CGPoint) {
        let view = View()
        let size = beaconSize
        view.frame = CGRect(x: point.x, y: point.y, width: size, height: size)
        view.layer?.backgroundColor = NSColor.red.cgColor
        view.layer?.cornerRadius = size / 2
        //let pan = NSPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        //view.addGestureRecognizer(pan)
        addSubview(view)
        
        let textH: CGFloat = 15
        let label = NSTextField(frame: CGRect(x: 0, y: (size - textH) / 2, width: size, height: textH))
        label.drawsBackground = false
        label.isBezeled = false
        label.isEditable = false
        label.backgroundColor = NSColor.clear
        label.stringValue = "\(beacons.count + 1)"
        label.font = NSFont.systemFont(ofSize: 12)
        label.alignment = .center
        view.addSubview(label)
        beacons.append(view)
        
        let radius = View()
        if beacons.count == 1 {
            radius.layer?.backgroundColor = NSColor.orange.withAlphaComponent(0.5).cgColor
        } else if beacons.count == 2 {
            radius.layer?.backgroundColor = NSColor.blue.withAlphaComponent(0.5).cgColor
        } else {
             radius.layer?.backgroundColor = NSColor.green.withAlphaComponent(0.5).cgColor
        }
        radiusViews.append(radius)
    }
    
    //distance from beacon 1, 2, 3
    func updateUser(dist1: CGFloat, dist2: CGFloat, dist3: CGFloat) {
        layoutRadius(dist: dist1, index: 0)
        layoutRadius(dist: dist2, index: 1)
        layoutRadius(dist: dist3, index: 2)
        //beacon 1 to 3
        let firstPoint = calcCircleIntersect(pointOne: beacons[0].frame.origin, radiusOne: dist1 * meterToPixel, pointTwo: beacons[2].frame.origin, radiusTwo: dist3 * meterToPixel)
        //beacon 2 to 3
        let secondPoint = calcCircleIntersect(pointOne: beacons[1].frame.origin, radiusOne: dist2 * meterToPixel, pointTwo: beacons[2].frame.origin, radiusTwo: dist3 * meterToPixel)
//        //beacon 2 to 1
        let thirdPoint = calcCircleIntersect(pointOne: beacons[0].frame.origin, radiusOne: dist1 * meterToPixel, pointTwo: beacons[1].frame.origin, radiusTwo: dist2 * meterToPixel)
        
        //don't love this, will fix properly soon
        let maxDist: CGFloat = 1
        let newPoint = calcCircleIntersect(pointOne: firstPoint, radiusOne: maxDist * meterToPixel, pointTwo: beacons[2].frame.origin, radiusTwo: dist2 * meterToPixel, addInter: true)
        
        //DEBUG CODE
//        let rView = View()
//        rView.layer?.backgroundColor = NSColor.purple.withAlphaComponent(0.5).cgColor
//        let rad = (maxDist * 2) * meterToPixel
//        rView.frame = CGRect(x: (firstPoint.x  + beaconSize/2) - rad / 2, y: (firstPoint.y + beaconSize/2) - rad / 2, width: rad, height: rad)
//        rView.layer?.cornerRadius = rad / 2
//        addSubview(rView)
        
        Swift.print("firstPoint: (\(firstPoint.x),\(firstPoint.y))")
        Swift.print("secondPoint: (\(secondPoint.x),\(secondPoint.y))")
        Swift.print("thirdPoint: (\(thirdPoint.x),\(thirdPoint.y))")
        Swift.print("newPoint: (\(newPoint.x),\(newPoint.y))")
        fakeView.frame.origin = CGPoint(x: firstPoint.x, y: newPoint.y) //this is garbage, get proper math figured out
    }
    
    func layoutRadius(dist: CGFloat, index: Int) {
        let rad = (dist * 2) * meterToPixel
        let rView = radiusViews[index]
        rView.frame = CGRect(x: NSMidX(beacons[index].frame) - rad / 2 , y: NSMidY(beacons[index].frame) - rad / 2, width: rad, height: rad)
        rView.layer?.cornerRadius = rad / 2
        addSubview(rView)
    }
    
    func didPan(_ pan: NSPanGestureRecognizer) {
        let location = pan.location(in: self)
        guard let bView = pan.view else {return}
        bView.frame.origin = location
        for view in beacons {
            if view === bView {
                continue
            }
            let distance = calcDistance(one: bView.frame.origin, two: view.frame.origin)
            Swift.print("distance from other beacon: \(distance)")
        }
    }
    
    func calcDistance(one: CGPoint, two: CGPoint) -> CGFloat {
        let xDist = one.x - two.x
        let yDist = one.y - two.y
        let distance = hypot(xDist,yDist)//sqrt((xDist * xDist) + (yDist * yDist))
        return distance
    }
    
    //adaption of circle_circle_intersection from http://paulbourke.net/geometry/circlesphere/tvoght.c
    func calcCircleIntersect(pointOne: CGPoint, radiusOne: CGFloat, pointTwo: CGPoint, radiusTwo: CGFloat, addInter: Bool = false) -> CGPoint {
        let xDist = pointOne.x - pointTwo.x
        let yDist = pointOne.y - pointTwo.y
        let d = hypot(xDist,yDist)
        //Check for solvability.
        if d > (radiusOne + radiusTwo) || d < fabs(radiusOne - radiusTwo) {
            //no solution. circles do not intersect
            Swift.print("circle's don't intersect")
            return CGPoint.zero //should probably be nil, but should never happen...
        }
        
         //'point 2' is the point where the line through the circle
         //intersection points crosses the line between the circle centers.
        
        //Determine the distance from point 0 to point 2.
        let a = ((radiusOne * radiusOne) - (radiusTwo * radiusTwo) + (d * d)) / (2.0 * d)
        
        //Determine the coordinates of point 2.
        let x2 = pointTwo.x + (xDist * a/d)
        let y2 = pointTwo.y + (yDist * a/d)
        
        //Determine the distance from point 2 to either of the intersection points.
        let h = sqrt((radiusOne * radiusOne) - (a*a))
        
        //Now determine the offsets of the intersection points from point 2.
        let rx = -yDist * (h/d)
        let ry = xDist * (h/d)
        
//        Swift.print("pointOne is x: \(pointOne.x), y: \(pointOne.y)")
//        Swift.print("pointTwo is x: \(pointTwo.x), y: \(pointTwo.y)")
//        Swift.print("the new point is x: \(x2), y: \(y2)")
        Swift.print("intersection offset is x: \(rx), y: \(ry)")
//        Swift.print("prime point is x: \(x2 - rx), y: \(y2 - ry)")
//        Swift.print("standard point is x: \(x2 + rx), y: \(y2 + ry)")
        var point = CGPoint(x: x2, y: y2)
        if addInter {
            point.y -= ry
        }
        return point
    }
}
