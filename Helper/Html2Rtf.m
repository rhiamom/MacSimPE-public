//
//  Html2Rtf.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/21/25.
//
// ***************************************************************************
// *   Copyright (C) 2005 by Ambertation                                     *
// *   quaxi@ambertation.de                                                  *
// *                                                                         *
// *   Objective-C translation Copyright (C) 2025 by GramzeSweatShop         *
// *   rhiamom@mac.com                                                       *
// *                                                                         *
// *   This program is free software; you can redistribute it and/or modify  *
// *   it under the terms of the GNU General Public License as published by  *
// *   the Free Software Foundation; either version 2 of the License, or     *
// *   (at your option) any later version.                                   *
// *                                                                         *
// *   This program is distributed in the hope that it will be useful,       *
// *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
// *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
// *   GNU General Public License for more details.                          *
// *                                                                         *
// *   You should have received a copy of the GNU General Public License     *
// *   along with this program; if not, write to the                         *
// *   Free Software Foundation, Inc.,                                       *
// *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
// ***************************************************************************/

#import "Html2Rtf.h"

@implementation Html2Rtf

+ (NSString *)convert:(NSString *)html {
    if (!html) return nil;
    
    NSMutableString *result = [html mutableCopy];
    NSError *error = nil;
    
    // Basic cleanup
    [result replaceOccurrencesOfString:@"\n" withString:@" " options:0 range:NSMakeRange(0, result.length)];
    
    // Remove double spaces
    while ([result containsString:@"  "]) {
        [result replaceOccurrencesOfString:@"  " withString:@" " options:0 range:NSMakeRange(0, result.length)];
    }
    
    // Escape RTF special characters
    [result replaceOccurrencesOfString:@"\\" withString:@"/" options:0 range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"{" withString:@"(" options:0 range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"}" withString:@")" options:0 range:NSMakeRange(0, result.length)];
    
    // Line breaks and paragraphs
    [result replaceOccurrencesOfString:@"<br />" withString:@"\\pard\\par\n" options:0 range:NSMakeRange(0, result.length)];
    
    // Paragraph tags with regex
    NSRegularExpression *pTagRegex = [NSRegularExpression regularExpressionWithPattern:@"<p[^>]*>" options:0 error:&error];
    [pTagRegex replaceMatchesInString:result options:0 range:NSMakeRange(0, result.length) withTemplate:@"\\pard\\f0\\fs16 "];
    
    [result replaceOccurrencesOfString:@"</p>" withString:@"\\par\\pard\\par\n" options:0 range:NSMakeRange(0, result.length)];
    
    // Headers
    [result replaceOccurrencesOfString:@"<h2>" withString:@"\\viewkind4\\uc1\\pard\\b\\f0\\fs16 " options:0 range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"</h2>" withString:@"\\b0\\par" options:0 range:NSMakeRange(0, result.length)];
    
    // Links with regex
    NSRegularExpression *linkRegex = [NSRegularExpression regularExpressionWithPattern:@"<a (.*?)href=\"([^\"]*)\"[^>]*>(.*?)<\\/a>" options:0 error:&error];
    [linkRegex replaceMatchesInString:result options:0 range:NSMakeRange(0, result.length) withTemplate:@"$3 ($2)"];
    
    // Div tags
    NSRegularExpression *divOpenRegex = [NSRegularExpression regularExpressionWithPattern:@"<div[^>]*>" options:0 error:&error];
    [divOpenRegex replaceMatchesInString:result options:0 range:NSMakeRange(0, result.length) withTemplate:@""];
    [result replaceOccurrencesOfString:@"</div>" withString:@"" options:0 range:NSMakeRange(0, result.length)];
    
    // XML/body cleanup
    NSRegularExpression *xmlBodyRegex = [NSRegularExpression regularExpressionWithPattern:@"<\\?xml(.*?)<body>" options:0 error:&error];
    [xmlBodyRegex replaceMatchesInString:result options:0 range:NSMakeRange(0, result.length) withTemplate:@""];
    
    NSRegularExpression *endBodyRegex = [NSRegularExpression regularExpressionWithPattern:@"</body>.*" options:0 error:&error];
    [endBodyRegex replaceMatchesInString:result options:0 range:NSMakeRange(0, result.length) withTemplate:@""];
    
    // Images
    NSRegularExpression *imgRegex = [NSRegularExpression regularExpressionWithPattern:@"<img [ ]*src=\"([^\"]*)\"[^>]*>" options:0 error:&error];
    [imgRegex replaceMatchesInString:result options:0 range:NSMakeRange(0, result.length) withTemplate:@""];
    
    // Lists
    [result replaceOccurrencesOfString:@"<ul>" withString:@"{\\*\\pn\\pnlvlblt\\pnf1\\pnindent0{\\pntxtb\\'B7}}\\fi-284\\li426 " options:0 range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"</ul>" withString:@"\\pard\\par\n" options:0 range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"<li>" withString:@"{\\pntext\\f1\\'B7\\tab}" options:0 range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"</li>" withString:@"\\par " options:0 range:NSMakeRange(0, result.length)];
    
    // URL replacements
    [result replaceOccurrencesOfString:@"../" withString:@"http://sims.ambertation.de/" options:0 range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"./" withString:@"http://sims.ambertation.de/" options:0 range:NSMakeRange(0, result.length)];
    
    // Clean up spaces before backslashes
    while ([result containsString:@" \\"]) {
        [result replaceOccurrencesOfString:@" \\" withString:@"\\" options:0 range:NSMakeRange(0, result.length)];
    }
    
    // Span tags with serif class
    NSRegularExpression *spanSerifRegex = [NSRegularExpression regularExpressionWithPattern:@"<span [ ]*class=\"([^\"]*)serif([^\"]*)\"[^>]*>(.*?)<\\/span>" options:0 error:&error];
    [spanSerifRegex replaceMatchesInString:result options:0 range:NSMakeRange(0, result.length) withTemplate:@"\\cf1 $3\\cf0 "];
    
    // Other span tags
    NSRegularExpression *spanRegex = [NSRegularExpression regularExpressionWithPattern:@"<span [ ]*class=\"([^\"]*)\"[^>]*>(.*?)<\\/span>" options:0 error:&error];
    [spanRegex replaceMatchesInString:result options:0 range:NSMakeRange(0, result.length) withTemplate:@"$2"];
    
    // Bold/Strong
    [result replaceOccurrencesOfString:@"<b>" withString:@"\\b " options:0 range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"<strong>" withString:@"\\b " options:0 range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"</b>" withString:@"\\b0 " options:0 range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"</strong>" withString:@"\\b0 " options:0 range:NSMakeRange(0, result.length)];
    
    // Underline
    [result replaceOccurrencesOfString:@"<u>" withString:@"\\ul " options:0 range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"</u>" withString:@"\\ulnone " options:0 range:NSMakeRange(0, result.length)];
    
    // Italic/Emphasis
    [result replaceOccurrencesOfString:@"<i>" withString:@"\\i " options:0 range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"<em>" withString:@"\\i " options:0 range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"</i>" withString:@"\\i0 " options:0 range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"</em>" withString:@"\\i0 " options:0 range:NSMakeRange(0, result.length)];
    
    // HTML entities
    [result replaceOccurrencesOfString:@"&nbsp;" withString:@" " options:0 range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"&auml;" withString:@"ä" options:0 range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"&ouml;" withString:@"ö" options:0 range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"&uuml;" withString:@"ü" options:0 range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"&Auml;" withString:@"Ä" options:0 range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"&Ouml;" withString:@"Ö" options:0 range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"&Uuml;" withString:@"Ü" options:0 range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"&szlig;" withString:@"ß" options:0 range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"&quot;" withString:@"\"" options:0 range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"&amp;" withString:@"&" options:0 range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"&lt;" withString:@"<" options:0 range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"&gt;" withString:@">" options:0 range:NSMakeRange(0, result.length)];
    
    // Build final RTF document
    NSMutableString *rtf = [[NSMutableString alloc] init];
    [rtf appendString:@"{\\rtf1\\ansi\\ansicpg1252\\deff0\\deflang1031{\\fonttbl{\\f0\\fswiss\\fprq2\\fcharset0 Verdana;}{\\f1\\fnil\\fcharset2 Symbol;}}"];
    [rtf appendString:@"{\\colortbl ;\\red215\\green120\\blue0;}"];
    [rtf appendString:result];
    [rtf appendString:@"}"];
    
    return [rtf copy];
}

@end
