LAN0_NODES=1
LAN1_NODES=1

all: compose.yaml

compose.yaml: compose.jsonnet
	jsonnet --tla-code lan0_nodes=$(LAN0_NODES) --tla-code lan1_nodes=$(LAN1_NODES) -o $@ $<

.PHONY: compose-up compose-down
compose-up: compose.yaml
	docker compose build
	docker compose up -d
compose-down: compose.yaml
	docker compose down --remove-orphans

clean:
	rm -f compose.yaml
