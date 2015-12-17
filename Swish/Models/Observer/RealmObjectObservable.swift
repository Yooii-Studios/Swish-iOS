//
//  RealmObjectObservable.swift
//  Swish
//
//  Created by 정동현 on 2015. 12. 17..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import ReactKit

typealias ReferenceCount = Int

enum BaseStreams<Key: Hashable, Value> {
    typealias T = Dictionary<Key, (Stream<Value>, ReferenceCount)>
}

protocol RealmObjectObservable {}

extension RealmObjectObservable {
    
    static func observeWithKey<Key: Hashable, Result>(key: Key,
        inout intoStreams streams: BaseStreams<Key, Result>.T,
        createStreamClosure: () -> Stream<Result>, handler: Result -> Void) {
            if streams[key] == nil {
                streams[key] = (createStreamClosure(), 1)
            } else {
                streams[key]!.1++
            }
            streams[key]!.0 ~> { result in
                handler(result)
            }
    }
    
    static func unobserveWithKey<Key: Hashable, Result>(key: Key,
        inout fromStream stream: BaseStreams<Key, Result>.T) {
            stream[key]?.0.cancel()
            stream[key]?.1--
            
            if stream[key]?.1 <= 0 {
                stream[key] = nil
            }
    }
}
