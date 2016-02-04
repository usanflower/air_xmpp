/*
 * Copyright (C) 2003-2012 Igniterealtime Community Contributors
 *
 *     Daniel Henninger
 *     Derrick Grigg <dgrigg@rogers.com>
 *     Juga Paazmaya <olavic@gmail.com>
 *     Nick Velloff <nick.velloff@gmail.com>
 *     Sean Treadway <seant@oncotype.dk>
 *     Sean Voisen <sean@voisen.org>
 *     Mark Walters <mark@yourpalmark.com>
 *     Michael McCarthy <mikeycmccarthy@gmail.com>
 *
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.igniterealtime.xiff.message
{
	import flash.events.EventDispatcher;
	
	import org.igniterealtime.xiff.core.IXMPPConnection;
	import org.igniterealtime.xiff.core.UnescapedJID;
	import org.igniterealtime.xiff.data.IQ;
	import org.igniterealtime.xiff.data.message.ArchiveAutomaticExtension;
	import org.igniterealtime.xiff.data.message.ArchiveListExtension;
	import org.igniterealtime.xiff.data.message.ArchiveManualExtension;
	import org.igniterealtime.xiff.data.message.ArchiveMaxExtension;
	import org.igniterealtime.xiff.data.message.ArchivePreferenceExtension;
	import org.igniterealtime.xiff.data.message.ArchiveRetrieveExtension;
	import org.igniterealtime.xiff.events.MessageArchiveEvent;
	import org.igniterealtime.xiff.util.DateTimeParser;
	
	/**
	 * Dispatched when pref element is received
	 *
	 * @eventType org.igniterealtime.xiff.events.MessageArchiveEvent.PREF_RECEIVED
	 */
	[Event( name="prefReceived", type="org.igniterealtime.xiff.events.MessageArchiveEvent" )]
	/**
	 * Dispatched when an error related to pref has arrived
	 *
	 * @eventType org.igniterealtime.xiff.events.MessageArchiveEvent.PREF_ERROR
	 */
	[Event( name="prefError", type="org.igniterealtime.xiff.events.MessageArchiveEvent" )]
	/**
	 * Dispatched when server returns successful response once item is removed
	 *
	 * @eventType org.igniterealtime.xiff.events.MessageArchiveEvent.ITEM_REMOVED
	 */
	[Event( name="itemRemoved", type="org.igniterealtime.xiff.events.MessageArchiveEvent" )]
	/**
	 * Dispatched when a collection list is received
	 *
	 * @eventType org.igniterealtime.xiff.events.MessageArchiveEvent.COLLECTION_RECEIVED
	 */
	[Event( name="listResult", type="org.igniterealtime.xiff.events.MessageArchiveEvent" )]
	
	[Event( name="listError", type="org.igniterealtime.xiff.events.MessageArchiveEvent" )]
	
	[Event( name="retrieveResult", type="org.igniterealtime.xiff.events.MessageArchiveEvent" )]
	
	[Event( name="retrieveError", type="org.igniterealtime.xiff.events.MessageArchiveEvent" )]
	
	
	/**
	 * Manager for XEP-0136: Message Archiving
	 *
	 * @see http://xmpp.org/extensions/xep-0136.html
	 */
	public class MessageArchiveManager extends EventDispatcher
	{
		private var _connection:IXMPPConnection;

		private var _listCount:int;
		private var _listLast:int;
		private var _listFirst:int;
		private var _chatListArray:Array;
		private var _chatRetrieveArray:Array;
		/**
		 * Manage client registration and password changing.
		 *
		 * @param	aConnection A reference to the <code>XMPPConnection</code> instance to use.
		 */
		public function MessageArchiveManager( aConnection:IXMPPConnection )
		{
			connection = aConnection;
        }

		public function get chatRetrieveArray():Array
		{
			return _chatRetrieveArray;
		}

		public function set chatRetrieveArray(value:Array):void
		{
			_chatRetrieveArray = value;
		}

		public function get chatListArray():Array
		{
			return _chatListArray;
		}

		public function set chatListArray(value:Array):void
		{
			_chatListArray = value;
		}

		public function get listFirst():int
		{
			return _listFirst;
		}

		public function set listFirst(value:int):void
		{
			_listFirst = value;
		}

		public function get listLast():int
		{
			return _listLast;
		}

		public function set listLast(value:int):void
		{
			_listLast = value;
		}

		public function get listCount():int
		{
			return _listCount;
		}

		public function set listCount(value:int):void
		{
			_listCount = value;
		}

		/**
		 * Retrieving a List of Collections.
		 *
		 * <p>To request a list of collections, the client sends a <strong>list</strong> element.
		 * The 'start' and 'end' attributes MAY be specified to indicate a date range (the values
		 * of these attributes MUST be UTC and adhere to the DateTime format specified in XEP-0082).
		 * The 'with' attribute MAY specify the JIDs of XMPP entities (see the JID Matching
		 * section of this document).</p>
		 *
		 * <p>If the 'with' attribute is omitted then collections with any JID are returned.
		 * If only 'start' is specified then all collections on or after that date should be
		 * returned. If only 'end' is specified then all collections prior to that date should
		 * be returned.</p>
		 *
		 * <p>The client SHOULD use Result Set Management to limit the number of collections
		 * returned by the server in a single stanza, taking care not to request a page of
		 * collections that is so big it might exceed rate limiting restrictions.</p>
		 */
		public function getCollectionList(withJid:UnescapedJID, start:Date = null, end:Date = null):void
		{
			var iq:IQ = new IQ(null, IQ.TYPE_GET, null, collectionList_callback, collectionError_callback);
			var ext:ArchiveListExtension = new ArchiveListExtension();
			ext.withJid = withJid;
			ext.start = start;
			ext.end = end;
			
			var exMax:ArchiveMaxExtension	=	new ArchiveMaxExtension;
			exMax.max	=	"30";
			
			ext.addExtension(exMax);
			
			iq.addExtension(ext);
			_connection.send(iq);
		}
		
		private function collectionError_callback(iq:IQ):void
		{
			var event:MessageArchiveEvent = new MessageArchiveEvent(MessageArchiveEvent.LIST_ERROR);
			dispatchEvent( event );
		}
		
		/**
		 *
		 * @param	iq
		 */
		protected function collectionList_callback( iq:IQ ):void
		{
			namespace ns = "list_collection";
			use namespace ns;
			
			if ( iq.type == IQ.TYPE_RESULT )
			{
				var node:XML = XML( iq.xml );
				var nodeChildren:XML = node.children()[0];
				if ( !nodeChildren )
				{
					return;
				}
				
				var nodes:XMLList = nodeChildren.children();
				_chatListArray	=	new Array;	
				for each ( var child:XML in nodes )
				{
					switch ( child.localName() )
					{
						case "set":
							for each (var setChild:XML in child.children()) 
							{
								switch(setChild.localName()){
									case "count":
										_listCount	=	int(setChild);
										break;
									case "last":
										_listLast	=	int(setChild);
										break;
									case "first":
										_listFirst	=	int(setChild);
										break;
								}
							}
							break;
						case "chat":
							var obj:Object	=	new Object;
							obj.With	=	child.attribute('with').toString();
							obj.start	=	child.attribute('start');
							obj.date	=	DateTimeParser.string2dateTime(child.attribute('start'));
							_chatListArray.push(obj);
							break;
							
							
					}
				}
				
				var event:MessageArchiveEvent = new MessageArchiveEvent(MessageArchiveEvent.LIST_RESULT);
				dispatchEvent( event );
			}
			else
			{
				// ?
			}
		}
		
		public function getRetrieve(withJid:UnescapedJID, start:String):void
		{
			var iq:IQ = new IQ(null, IQ.TYPE_GET, null, retrieve_callback, retrieveError_callback);
			var ext:ArchiveRetrieveExtension = new ArchiveRetrieveExtension();
			ext.withJid = withJid;
			ext.start = start;
			
			var exMax:ArchiveMaxExtension	=	new ArchiveMaxExtension;
			exMax.max	=	"100";
			
			ext.addExtension(exMax);
			
			iq.addExtension(ext);
			_connection.send(iq);
		}
		
		private function retrieveError_callback(iq:IQ):void
		{
			var event:MessageArchiveEvent = new MessageArchiveEvent(MessageArchiveEvent.RETRIEVE_ERROR);
			dispatchEvent( event );
		}
		
		/**
		 *
		 * @param	iq
		 */
		protected function retrieve_callback( iq:IQ ):void
		{
			namespace ns = "retrieve_list";
			use namespace ns;
			
			if ( iq.type == IQ.TYPE_RESULT )
			{
				var node:XML = XML( iq.xml );
				var nodeChildren:XML = node.children()[0];
				var resultDate:Date
				if(nodeChildren.localName() == 'chat'){
					resultDate	=	DateTimeParser.string2dateTime(nodeChildren.attribute('start'));
				}
				
				var nodes:XMLList = nodeChildren.children();
				_chatRetrieveArray	=	new Array;	
				for each ( var child:XML in nodes )
				{
					switch ( child.localName() )
					{
						case "set":
							for each (var setChild:XML in child.children()) 
						{
							switch(setChild.localName()){
								case "count":
									_listCount	=	int(setChild);
									break;
								case "last":
									_listLast	=	int(setChild);
									break;
								case "first":
									_listFirst	=	int(setChild);
									break;
							}
						}
							break;
						case "to":
						case "from":
							var obj:Object	=	new Object;
							resultDate.setSeconds(resultDate.getSeconds()+int(child.attribute('secs').toString()))
							
							obj.type	=	child.localName();
							obj.body	=	child.children()[0].toString();
							obj.date	=	new Date(resultDate);
							_chatRetrieveArray.push(obj);
							break;
					}
				}
				
				var event:MessageArchiveEvent = new MessageArchiveEvent(MessageArchiveEvent.RETRIEVE_RESULT);
				dispatchEvent( event );
			}
			else
			{
				// ?
			}
		}
		

		/**
		 * The instance of the XMPPConnection class to use for sending and
		 * receiving data.
		 */
		public function get connection():IXMPPConnection
		{
			return _connection;
		}
		public function set connection( value:IXMPPConnection ):void
		{
			_connection = value;
			_connection.enableExtensions(
				ArchiveAutomaticExtension,
				ArchiveListExtension,
				ArchiveManualExtension,
				ArchivePreferenceExtension
			);
		}
	}

}
