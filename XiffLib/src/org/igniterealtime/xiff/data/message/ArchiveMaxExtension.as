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
package org.igniterealtime.xiff.data.message
{
    import org.igniterealtime.xiff.data.Extension;
	import org.igniterealtime.xiff.data.IExtension;
	import org.igniterealtime.xiff.core.UnescapedJID;
	import org.igniterealtime.xiff.util.DateTimeParser;
	
	/**
	 * XEP-0136: Message Archiving
	 *
	 * @see http://xmpp.org/extensions/xep-0136.html
	 */
	public class ArchiveMaxExtension extends Extension implements IExtension
	{
		public static const ELEMENT_NAME:String = "set";
		
		/**
		 *
		 * @param	parent
		 */
		public function ArchiveMaxExtension( parent:XML = null )
		{
			super(parent);
		}
		
		public function getNS():String
		{
			return "http://jabber.org/protocol/rsm";
		}
		
		public function getElementName():String
		{
			return ArchiveMaxExtension.ELEMENT_NAME;
        }
		
		public function get max():String
		{
			return getField("max");
		}
		public function set max(value:String):void
		{
			setField("max", value);
			//setAttribute("xmlns","http://jabber.org/protocol/rsm");
		}
		
	}
}
