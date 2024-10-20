//
//  Communication.swift
//  cal_hacks_emergency_app
//
//  Created by Richard Wei on 10/19/24.
//

import SwiftyZeroMQ5
import SwiftMsgPack
import Network
import NetworkExtension

class CommunicationClass{
    static public let obj = CommunicationClass();
        
    internal var context : SwiftyZeroMQ.Context?;
    internal var pair : SwiftyZeroMQ.Socket?;
    
    internal var connectionString : String?;
            
    //
    
    private init(){
        printVersion();
        do{
            context = try SwiftyZeroMQ.Context();
            pair = try context?.socket(.pair);
        }
        catch{
            print("Unable to create ZeroMQ context");
        }
    }
    
    public func printVersion(){
        let (major, minor, patch, _) = SwiftyZeroMQ.version;
        print("ZeroMQ library version is \(major).\(minor) with patch level .\(patch)");
        print("SwiftyZeroMQ version is \(SwiftyZeroMQ.frameworkVersion)");
    }
    
    //
    
    public func sendData(_ data: Data){
        do {
            try getSocket()?.send(data: data)
        }
        catch {
            print("ERROR SENDING: \(error)")
        }
    }
    
    //
    
    public func connect(){
    
        // first needs to connect to the FRED wifi network
        let networkHotspot = NEHotspotConfiguration(ssid: "FRED_WIFI", passphrase: "FRED_PASSWORD", isWEP: false)

        NEHotspotConfigurationManager.shared.apply(networkHotspot) { (error) in
          // Act upon setup connection to the hotspot
            do{
                try self.pair?.connect("tcp://192.168.220.1:5556");
            }
            catch{
                print("Connect communication error - \(error) - \(self.convertErrno(zmq_errno()))");
            }
        }
    }
    
    public func disconnect() -> Bool{
        var isSuccessful = true;
        
        do{
            try pair?.disconnect("tcp://192.168.220.1:5556");
        }
        catch{
            print("Disconnect communication error - \(error) - \(convertErrno(zmq_errno()))");
            isSuccessful = false;
        }
        
        return isSuccessful;
    }
    
    private func getSocket() -> SwiftyZeroMQ.Socket?{
        return pair;
    }
    
    public func convertErrno(_ errorn: Int32) -> String{
        switch errorn {
        case EAGAIN:
            return "EAGAIN - Non-blocking mode was requested and no messages are available at the moment.";
        case ENOTSUP:
            return "ENOTSUP - The zmq_recv() operation is not supported by this socket type.";
        case EFSM:
            return "EFSM - The zmq_recv() operation cannot be performed on this socket at the moment due to the socket not being in the appropriate state.";
        case ETERM:
            return "ETERM - The ØMQ context associated with the specified socket was terminated.";
        case ENOTSOCK:
            return "ENOTSOCK - The provided socket was invalid.";
        case EINTR:
            return "EINTR - The operation was interrupted by delivery of a signal before a message was available.";
        case EFAULT:
            return "EFAULT - The message passed to the function was invalid.";
        default:
            return "Not valid errno code";
        }
    }
}
