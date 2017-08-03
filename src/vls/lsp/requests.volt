module vls.lsp.requests;

import watt.text.format;
import watt.json;

import vls.lsp.error;
import vls.lsp.constants;

/**
 * Return the URI from a TextDocument parameter.
 * Params:
 *   param = the param value from the RequestObject.
 * Returns: null if no error, or an Error object otherwise.
 */
fn parseTextDocument(param: Value, out uri: string) Error
{
	if (param.type() != DomType.OBJECT) {
		return Error.invalidParams("param is not an object");
	}
	if (!param.hasObjectKey("textDocument")) {
		return Error.invalidParams("param does not have a textDocument key");
	}
	td := param.lookupObjectKey("textDocument");
	if (td.type() != DomType.OBJECT) {
		return Error.invalidParams("param.textDocument is not an object");
	}
	if (!td.hasObjectKey("uri")) {
		return Error.invalidParams("param.textDocument has no uri key");
	}
	uriVal := td.lookupObjectKey("uri");
	if (uriVal.type() != DomType.STRING) {
		return Error.invalidParams("textDocument.uri isn't a string");
	}
	uri = uriVal.str();
	return null;
}

/**
 * Return changed URIs from a DidChangeWatchedFiles parameter.
 * Params:
 *   param = the param value from the RequestObject.
 * Returns: null if no error, or an Error object otherwise.
 */
fn parseDidChangeWatchedFiles(param: Value, out uris: string[]) Error
{
	if (param.type() != DomType.OBJECT) {
		return Error.invalidParams("param is not an object");
	}
	if (!param.hasObjectKey("changes")) {
		return Error.invalidParams("param does not have a changes key");
	}
	td := param.lookupObjectKey("changes");
	if (td.type() != DomType.ARRAY) {
		return Error.invalidParams("param.changes is not an array");
	}
	foreach (i, element; td.array()) {
		if (element.type() != DomType.OBJECT) {
			return Error.invalidParams(format("changes element %s is not an object", i));
		}
		if (!element.hasObjectKey("type")) {
			return Error.invalidParams(format("changes element %s does not have type key", i));
		}
		type := element.lookupObjectKey("type");
		if (type.type() != DomType.LONG) {
			return Error.invalidParams(format("changes element %s type key is not an integer", i));
		}
		if (type.integer() != FILE_CHANGED_CREATED || type.integer() != FILE_CHANGED_CHANGED) {
			continue;
		}
		if (!element.hasObjectKey("uri")) {
			return Error.invalidParams(format("changes element %s does not have uri key", i));
		}
		uriVal := element.lookupObjectKey("uri");
		if (uriVal.type() != DomType.STRING) {
			return Error.invalidParams(format("changes element %s's uri is not a string", i));
		}
		uris ~= uriVal.str();
	}
	return null;
}
