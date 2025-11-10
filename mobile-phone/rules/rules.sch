<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    xmlns:ai="http://www.oxygenxml.com/ai/function" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process" queryBinding="xslt3">
    <sch:ns uri="http://www.oxygenxml.com/ai/function" prefix="ai"/>
    
    <!-- 1. Each topic must have a non-empty <shortdesc> -->
    <sch:pattern id="shortdesc-required">
        <sch:rule context="topic | concept | task | reference">
            <sch:assert test="shortdesc" role="warn"
                sqf:fix="add-shortdesc add-shortdesc-ai"> Each topic must have a
                &lt;shortdesc&gt; element. </sch:assert>

            <sqf:fix id="add-shortdesc">
                <sqf:description>
                    <sqf:title>Add missing &lt;shortdesc&gt;</sqf:title>
                </sqf:description>
                <sqf:add match="title" target="shortdesc" node-type="element" position="after">
                    Provide a short description here. </sqf:add>
            </sqf:fix>
            <sch:let name="root" value="."/>
            <sqf:fix id="add-shortdesc-ai">
                <sqf:description>
                    <sqf:title>Generate &lt;shortdesc&gt; with AI</sqf:title>
                </sqf:description>
                <sqf:add match="title" target="shortdesc" node-type="element" position="after"
                    select="ai:transform-content('Rephrase the following text in a single phrase strictly less than 40 words.', $root)"/>
            </sqf:fix>
        </sch:rule>
    </sch:pattern>

    <!-- 2. <task> topics must contain at least one <step> inside <steps> -->
    <sch:pattern id="task-steps-required">
        <sch:rule context="task">
            <sch:assert test="taskbody/steps/step" sqf:fix="add-step"> &lt;task&gt; topics must
                contain at least one &lt;step&gt; inside &lt;steps&gt;. </sch:assert>
            <sqf:fix id="add-step">
                <sqf:description>
                    <sqf:title>Add missing &lt;step&gt; to &lt;steps&gt;</sqf:title>
                </sqf:description>
                <sqf:add match="taskbody/steps" node-type="element" target="step"
                    position="last-child"> Describe the first step here. </sqf:add>
            </sqf:fix>
        </sch:rule>
    </sch:pattern>

    <!-- 3. <concept> topics must not contain <steps> or <step> -->
    <sch:pattern id="concept-no-steps">
        <sch:rule context="concept">
            <sch:assert test="not(.//steps) and not(.//step)" sqf:fix="remove-steps-step">
                &lt;concept&gt; topics must not contain &lt;steps&gt; or &lt;step&gt; elements. </sch:assert>
            <sqf:fix id="remove-steps-step">
                <sqf:description>
                    <sqf:title>Remove &lt;steps&gt; and &lt;step&gt; from
                        &lt;concept&gt;</sqf:title>
                </sqf:description>
                <sqf:delete match=".//steps"/>
                <sqf:delete match=".//step"/>
            </sqf:fix>
        </sch:rule>
    </sch:pattern>

    <!-- 4. All <image> elements must have a non-empty @alt attribute -->
    <sch:pattern id="image-alt-required">
        <sch:rule context="image">
            <sch:assert test="alt and normalize-space(alt)" sqf:fix="add-alt add-alt-ai"> All
                &lt;image&gt; elements must have a non-empty alternate text. </sch:assert>
            <sqf:fix id="add-alt">
                <sqf:description>
                    <sqf:title>Add or edit alternate text</sqf:title>
                </sqf:description>
                <sqf:add target="alt" node-type="element" position="first-child">Describe the image here.</sqf:add>
            </sqf:fix>
            <sqf:fix id="add-alt-ai">
                <sqf:description>
                    <sqf:title>Generate alternate text from image with AI</sqf:title>
                </sqf:description>
                <sqf:add node-type="element" target="alt" position="first-child"
                    select="
                    ai:transform-content(
                    'Create a short alternate text description for this image:',
                    concat('${attach(', resolve-uri(@href, base-uri()), ')}'))"/>
            </sqf:fix>
        </sch:rule>
    </sch:pattern>

    <!-- 5. No topic should have more than one <title> element -->
    <sch:pattern id="single-title">
        <sch:rule context="topic | concept | task | reference">
            <sch:assert test="count(title) = 1" sqf:fix="fix-single-title"> Each topic must have
                exactly one &lt;title&gt; element. </sch:assert>
            <sqf:fix id="fix-single-title">
                <sqf:description>
                    <sqf:title>Remove extra &lt;title&gt; elements</sqf:title>
                </sqf:description>
                <sqf:delete match="title[position() &gt; 1]"/>
            </sqf:fix>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="topic-indexterm-required">
        <sch:rule context="topic">
            <sch:assert test="prolog/metadata/keywords" sqf:fix="addIndexTerm addIndexTerm_ai" role="warn"> No index
                term for topic.</sch:assert>
            <sch:let name="topic" value="."/>
            <sqf:fix id="addIndexTerm">
                <sqf:description>
                    <sqf:title>Add indexterm for topic</sqf:title>
                </sqf:description>
                <sqf:add match="body" node-type="element" target="prolog" position="before">
                    <metadata>
                        <keywords>
                            <indexterm>first</indexterm>
                            <indexterm>second</indexterm>
                        </keywords>
                    </metadata>
                </sqf:add>
            </sqf:fix>
            <sqf:fix id="addIndexTerm_ai">
                <sqf:description>
                    <sqf:title>Generate indexterm for topic with AI</sqf:title>
                </sqf:description>
                <sqf:add match="body" node-type="element" target="prolog" position="before">
                    <metadata>
                        <xsl:value-of
                            select="ai:invoke-action('action.generate.indexterms', 'Do not add mardown markers', $topic)"
                            disable-output-escaping="yes"/>
                    </metadata>
                </sqf:add>
            </sqf:fix>
        </sch:rule>
    </sch:pattern>
</sch:schema>
