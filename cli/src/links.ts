import * as fs from "node:fs";

/** Create a directory link without requiring Windows developer-mode symlink privileges. */
export function createDirectoryLink(source: string, target: string): void {
  fs.symlinkSync(source, target, process.platform === "win32" ? "junction" : "dir");
}
