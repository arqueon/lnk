# >>> agent-resume >>>
# Agent resume (herdr-agent-resume): a restored Herdr terminal starts its agent again.
# Set AGENT_RESUME_AUTO=0 to pause it; `install.py --no-auto` removes these lines.
if status is-interactive; and set -q HC_TERMINAL_ID
    function __agent_resume --on-event fish_prompt
        functions -e __agent_resume
        if test "$AGENT_RESUME_AUTO" != 0; and test -f '/home/ruben/.config/herdr-app/mods/agent-resume/agent_resume.py'
            command python3 '/home/ruben/.config/herdr-app/mods/agent-resume/agent_resume.py' here; or command python3 '/home/ruben/.config/herdr-app/mods/agent-resume/agent_resume.py' after $status
        end
    end
end
# <<< agent-resume <<<
