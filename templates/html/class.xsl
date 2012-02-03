<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:src="http://xml.phpdox.de/src#"
    exclude-result-prefixes="#default src">
    
    <xsl:import href="topbar.xsl" />

    <xsl:output method="xml" indent="yes" encoding="utf-8" doctype-public="html" />
    
    <xsl:param name="classname" />

    <xsl:variable name="project" select="phe:getProjectNode()"/>
    <xsl:variable name="class" select="//src:class[@full=$classname]" />

    <xsl:template match="/">
        <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
            <head>
                <meta charset="UTF-8" />
                <link rel="stylesheet" href="../css/bootstrap.min.css" />
                <title><xsl:value-of select="$project/@name" /> - <xsl:value-of select="$classname" /> - API Documentation</title>
                <style type="text/css">
                    body {
                        padding-top: 60px;
                    }
                </style>                
            </head>
            <body>
                <xsl:call-template name="topbar">
                    <xsl:with-param name="rel" select="'..'" />                    
                </xsl:call-template>
                
                <div class="container-fluid">
                
                    <xsl:call-template name="sidebar" />
                    
                    <div class="content">
                        <div class="well">
                            <small><xsl:value-of select="$class/../@name" /></small><h1><xsl:value-of select="$class/@name" /></h1>
                            
                            <ul class="unstyled"> 
                            <xsl:apply-templates select="$class/src:docblock/*[local-name()!='description']">
                                <xsl:sort select="local-name()" order="ascending" />
                            </xsl:apply-templates>
                            </ul>

                            <xsl:for-each select="$class/src:docblock/src:description">
                                <p style="font-size:110%;">
                                    <xsl:value-of select="@compact" />
                                    <xsl:if test="text() != ''">
                                        <pre><xsl:value-of select="." /></pre>
                                    </xsl:if>
                                </p>
                            </xsl:for-each>
                        </div>
                    
                        <xsl:if test="$class/src:constant">
                            <h2>Constants</h2>
                            <section style="padding-left:1em;">    
                                <ul class="unstyled">                                
                                    <xsl:apply-templates select="$class/src:constant" />
                                </ul>
                            </section>
                        </xsl:if>
                        <xsl:if test="$class/src:member">
                            <h2>Members</h2>
                            <section style="padding-left:1em;">    
                                <ul class="unstyled">
                                    <xsl:apply-templates select="$class/src:member" />
                                </ul>
                            </section>
                        </xsl:if>
                        <xsl:if test="$class/src:constructor|$class/src:destroctur|$class/src:method">
                            <h2>Methods</h2>
                            <section style="padding-left:1em;">
                            <ul class="unstyled">    
                                <xsl:apply-templates select="$class/src:constructor|$class/src:destructor" />
                                <xsl:apply-templates select="$class/src:method">
                                    <xsl:sort select="@visibility" order="descending" />
                                    <xsl:sort select="@name" />
                                </xsl:apply-templates>                                
                            </ul>
                            </section>
                        </xsl:if>
                        
                        <footer>
                            <p>Generated with phpDox 0.4</p>
                        </footer>
                    </div>            

                </div>
            </body>
        </html>

    </xsl:template>

    <xsl:template name="sidebar">
        <div class="sidebar">
            <div class="well">
                <xsl:if test="$class/src:constant">
                    <h5>Constants</h5>
                    <ul>
                        <xsl:for-each select="$class/src:constant">
                            <li><a href="#{@name}"><xsl:value-of select="@name" /></a></li>
                        </xsl:for-each>
                    </ul>
                </xsl:if>
                <xsl:if test="$class/src:member">
                    <h5>Members</h5>
                    <ul>
                        <xsl:for-each select="$class/src:member">
                            <li><a href="#{@name}">$<xsl:value-of select="@name" /></a></li>
                        </xsl:for-each>
                    </ul>
                </xsl:if>
                <xsl:if test="$class/src:method|$class/src:constructor|$class/src:destructor">
                    <h5>Methods</h5>
                    <ul>
                        <xsl:for-each select="$class/src:method|$class/src:constructor|$class/src:destructor">
                            <xsl:sort select="@name" order="ascending" />
                            <li><a href="#{@name}"><xsl:value-of select="@name" /></a></li>
                        </xsl:for-each>
                    </ul>
                </xsl:if>
            </div>
        </div>
    </xsl:template>
    
    <!--  ## DOCBLOCK NODES ## -->
    
    <xsl:template match="src:description">
        <li>
            <xsl:value-of select="@compact" />
            <xsl:if test="text() != ''">
                <pre><xsl:value-of select="." /></pre>
            </xsl:if>
        </li>
    </xsl:template>    

    <xsl:template match="src:author">
        <li>
            <b>Author: </b> <xsl:value-of select="@value" />
        </li>
    </xsl:template>

    <xsl:template match="src:copyright">
        <li>
            <b>Copyright: </b> <xsl:value-of select="@value" />
        </li>
    </xsl:template>

    <xsl:template match="src:license">
        <li>
            <b>License: </b> <xsl:value-of select="@name" />
        </li>
    </xsl:template>

    <xsl:template match="src:var">    
        <p><em><xsl:value-of select="src:docblock/src:var/@type" /></em></p>
    </xsl:template>

    <!--  ## CONSTANTS ## -->
    
    <!--  ## MEMBERS ## -->
    <xsl:template match="src:member">
        <li>
            <a name="{@name}" />
            <h3>$<xsl:value-of select="@name" /></h3>
            <div style="padding-left:1em;">
                <xsl:call-template name="modifiers">
                    <xsl:with-param name="ctx" select="." />
                </xsl:call-template>            
                <strong>&#160;$<xsl:value-of select="@name" /></strong>
                <xsl:for-each select="src:docblock">
                    <em>&#160;<xsl:value-of select="src:var/@type" /></em>
                    <p>
                        <xsl:apply-templates select="src:description" />
                    </p>                    
                </xsl:for-each>
                <xsl:if test="src:default">
                    <p><b>Default:</b>&#160;
		    <xsl:choose>
			    <xsl:when test="starts-with(src:default,'array')">
				<pre><code><xsl:value-of select="src:default" /></code></pre>
			    </xsl:when>
			<xsl:otherwise>
				<code><xsl:value-of select="src:default" /></code>
			</xsl:otherwise>
		    </xsl:choose>
		    </p>
                </xsl:if>
            </div>
            <hr />
        </li>
    </xsl:template>    
    
    <!--  ## METHODS ## -->
    <xsl:template match="src:method|src:constructor|src:destructor">
        <li>
            <a name="{@name}" />
            <h3><xsl:value-of select="@name" /><span style="font-size:90%;">( <xsl:apply-templates select="src:parameter[1]" /> )</span></h3>
            <section style="padding-left:1em;">
                <xsl:call-template name="modifiers">
                    <xsl:with-param name="ctx" select="." />
                </xsl:call-template>                            
                <xsl:for-each select="src:docblock">
                    <p style="font-size:110%; padding-top:5px;">
                        <xsl:apply-templates select="src:description" />
                    </p>                    
                </xsl:for-each>
		 <xsl:if test="src:parameter">
			<h4>Parameters</h4>
			<ul class="method-parameters">
				<xsl:apply-templates select="src:parameter[1]">
					<xsl:with-param name="full" select="'1'" />
				</xsl:apply-templates>
			</ul>
		</xsl:if>
            </section>
            <hr />
        </li>
    </xsl:template>    
    
    <xsl:template match="src:parameter">
	<xsl:param name="full" select="'0'" />
	<xsl:choose>
		<xsl:when test="$full = '1'">
			<li>
		<xsl:choose>
		    <xsl:when test="@type='object'">
			<em><xsl:copy-of select="phe:classLink(.)" />&#160;</em>
		    </xsl:when>
		    <xsl:when test="@type='{unknown}'">
			<xsl:variable name="name" select="@name" />
			<xsl:for-each select="src:docblock/src:param[@name=$name]">
			    <em><xsl:copy-of select="phe:classLink(.)" />&#160;</em>
			</xsl:for-each>            
		    </xsl:when>            
		    <xsl:otherwise>
			<em><xsl:value-of select="@type" />&#160;</em>
		    </xsl:otherwise>
		</xsl:choose>
		<strong>
		    <xsl:if test="@byreference = 'true'"></xsl:if>$<xsl:value-of select="@name" />
		</strong>
		<xsl:if test="src:default"><small><em> = <xsl:value-of select="src:default" /></em></small></xsl:if>
		<!--<xsl:if test="@optional = 'true'"><span class="parameter-optional"> [optional]</span></xsl:if>-->
		&#160;<xsl:value-of select="@description" />
			</li>
			<xsl:if test="following-sibling::src:parameter"><xsl:apply-templates select="following-sibling::src:parameter[1]"><xsl:with-param name="full" select="$full" /></xsl:apply-templates></xsl:if>
		</xsl:when>
		<xsl:otherwise>
			<xsl:if test="@optional = 'true'">[</xsl:if>
			<xsl:choose>
			    <xsl:when test="@type='object'">
				<em><xsl:copy-of select="phe:classLink(.)" /></em>&#160;
			    </xsl:when>
			    <xsl:when test="@type='{unknown}'">
				<xsl:variable name="name" select="@name" />
				<xsl:for-each select="src:docblock/src:param[@name=$name]">
				    <em><xsl:copy-of select="phe:classLink(.)" /></em>&#160;
				</xsl:for-each>            
			    </xsl:when>            
			    <xsl:otherwise>
				<em><xsl:value-of select="@type" /></em>&#160;
			    </xsl:otherwise>
			</xsl:choose>
			<strong>
			    <xsl:if test="@byreference = 'true'">&amp;</xsl:if>$<xsl:value-of select="@name" />
			</strong>
			<xsl:if test="src:default"><small> = <xsl:value-of select="src:default" /></small></xsl:if>
				<xsl:if test="following-sibling::src:parameter">, <xsl:apply-templates select="following-sibling::src:parameter[1]"><xsl:with-param name="full" select="$full" /></xsl:apply-templates></xsl:if>
			<xsl:if test="@optional = 'true'">&#160;]</xsl:if>
		</xsl:otherwise>
	</xsl:choose>
    </xsl:template>

    <xsl:template name="modifiers">
        <xsl:param name="ctx" />
        
        <xsl:for-each select="$ctx/@visibility">
            <span>
                <xsl:attribute name="class">label
                    <xsl:choose>
                        <xsl:when test=". = 'public'">success</xsl:when>
                        <xsl:when test=". = 'protected'">warning</xsl:when>
                        <xsl:when test=". = 'private'">important</xsl:when>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:value-of select="." />          
            </span>
        </xsl:for-each>
        
        <xsl:if test="$ctx/@static = 'true'">
            <span class="label">static</span>
        </xsl:if>

        <xsl:if test="$ctx/@final = 'true'">
            <span class="label notice">final</span>
        </xsl:if>

        <xsl:if test="$ctx/@abstract = 'true'">
            <span class="label">abstract</span>
        </xsl:if>
        
    </xsl:template>
</xsl:stylesheet>
