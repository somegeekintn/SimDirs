//
//  CUINamedLayerStack.h
//  SimDirs
//
//  Created by Casey Fleser on 4/30/16.
//  Copyright © 2016 Quiet Spark. All rights reserved.
//

#import "CUICatalog.h"

@interface CUINamedLayerStack : CUINamedImage

@property(retain, nonatomic) NSArray *layers; // @synthesize layers=_layers;

@property(readonly, nonatomic) struct CGImage *radiosityImage;
@property(readonly, nonatomic) struct CGImage *flattenedImage;
- (id)layerImageAtIndex:(unsigned long long)arg1;
@property(readonly, nonatomic) struct CGSize size;

@end

@interface CUINamedLayerImage : CUINamedImage

@property(nonatomic) int blendMode; // @synthesize blendMode=_blendMode;
@property(nonatomic) double opacity; // @synthesize opacity=_opacity;
@property(nonatomic) struct CGRect frame; // @synthesize frame=_frame;

@end
