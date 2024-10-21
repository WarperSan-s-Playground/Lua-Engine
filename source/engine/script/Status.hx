package engine.script;

/** The status of the script */
enum Status {
    OPEN;
    RUNNING;
    STALE;
    ERRORED;
    CLOSED;
}