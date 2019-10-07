from pathlib import Path

def findFullFilename(path, pattern):
    filenameGenerator = Path(path).glob(pattern)
    firstPath = next(filenameGenerator, None)
    if firstPath is None:
        return None
    return firstPath.name

def findPywFilenameHere(pattern):
    return findFullFilename(".", f"{pattern}*.pyw")