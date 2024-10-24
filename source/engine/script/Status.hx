package engine.script;

/** The status of the script */
enum Status
{
	OPEN; // The script is opened
	RUNNING; // The script is running
	STALE; // The script is stale
	ERRORED; // The script has errored
	CLOSED; // The script is closed
}
