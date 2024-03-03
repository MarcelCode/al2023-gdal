"""Deploy aws lambda layer."""

import click

from boto3.session import Session
from botocore.client import Config

AWS_REGIONS = [
    "us-west-2",
]

CompatibleRuntimes_al2 = [
    "provided.al2023",
]


@click.command()
@click.argument('gdal_version', type=str)
def main(gdal_version):
    """Build and Deploy Layers."""
    gdal_version_no_dot = gdal_version.replace(".", "")
    layer_name = f"gdal-minimal-{gdal_version_no_dot}"
    description = f"Lambda Layer with minimal GDAL{gdal_version} for Amazon Linux 2023"

    session = Session()

    # Increase connection timeout to work around timeout errors
    config = Config(connect_timeout=6000, retries={'max_attempts': 5})

    click.echo(f"Deploying {layer_name}", err=True)
    for region in AWS_REGIONS:
        click.echo(f"AWS Region: {region}", err=True)
        client = session.client("lambda", region_name=region, config=config)

        click.echo("Publishing new version", err=True)
        with open("package.zip", 'rb') as zf:
            res = client.publish_layer_version(
                LayerName=layer_name,
                Content={"ZipFile": zf.read()},
                CompatibleRuntimes=CompatibleRuntimes_al2,
                CompatibleArchitectures=["x86_64"],
                Description=description,
                LicenseInfo="MIT"
            )

        click.echo("Adding permission", err=True)
        client.add_layer_version_permission(
            LayerName=layer_name,
            VersionNumber=res["Version"],
            StatementId='make_public',
            Action='lambda:GetLayerVersion',
            Principal='*',
        )


if __name__ == '__main__':
    main()
